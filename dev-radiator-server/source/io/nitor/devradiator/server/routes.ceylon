/**
 * Copyright 2017 Nitor Creations Oy
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import com.julienviet.childprocess {
    Process
}

import io.nitor.api.backend.proxy {
    Proxy,
    DevNullProxyTracer,
    ProxyTracer
}
import io.vertx.core {
    ...
}
import io.vertx.core.buffer {
    Buffer
}
import io.vertx.core.http {
    ...
}
import io.vertx.ext.web {
    Router,
    RoutingContext
}

import java.lang {
    JInteger=Integer,
    JString=String
}
import java.util {
    JList=List,
    JArrayList=ArrayList
}
import java.util.\ifunction {
    Supplier
}

JList<JString> splitargs(String s) {
    value l = JArrayList<JString>();
    s.split().each((String arg) => l.add(JString(arg)));
    return l;
}

JList<JString> args(String* args) {
    value l = JArrayList<JString>();
    args.each((String arg) => l.add(JString(arg)));
    return l;
}

void setupProxy(Vertx vertx, Router router) {
    value client = vertx.createHttpClient(HttpClientOptions()
        .setConnectTimeout(10)
        .setIdleTimeout(120)
        .setMaxPoolSize(1000)
        .setPipelining(false)
        .setPipeliningLimit(1)
        .setMaxWaitQueueSize(20)
        .setUsePooledBuffers(true)
        .setProtocolVersion(HttpVersion.http11)
        .setTryUseCompression(false)
    );

    object targetResolver satisfies Proxy.TargetResolver {
        shared actual void resolveNextHop(RoutingContext routingContext, Handler<Proxy.Target> targetHandler) {
            targetHandler.handle(Proxy.Target("localhost", 3000, routingContext.request().uri(), "localhost:3000"));
        }
    }
    Proxy proxy = Proxy(client, targetResolver, serverIdleTimeout, 300, object satisfies Supplier<ProxyTracer> {
        shared actual ProxyTracer get() => DevNullProxyTracer();
    }, Proxy.DefaultPumpStarter());
    router.route().handler(proxy.handle);
    router.route().failureHandler(object satisfies Handler<RoutingContext> {
        shared actual void handle(RoutingContext routingContext) {
            if (routingContext.failed()) {
                assert (is Proxy.ProxyException ex = routingContext.failure());
                if (!routingContext.response().headWritten()) {
                    value statusMsg = if (exists cause = ex.cause) then cause.message else (ex.reason == Proxy.RejectReason.noHostHeader then "Exhausted resources while trying to extract Host header from the request" else "");
                    routingContext.response().setStatusCode(ex.statusCode);
                    routingContext.response().headers().set("content-type", "text/plain;charset=UTF-8");
                    routingContext.response().end(statusMsg);
                }
            } else {
                routingContext.next();
            }
        }
    });
}

Boolean devMode = false;

void setupRoutes(Vertx vertx, Router router) {
    /*
    if (devMode) {
        setupProxy(vertx, router); // dev
    } else {
        router.route("/*").handler(StaticHandler.create("web"));
    }
*/*/
    router.route().handler((RoutingContext ctx) {
        ctx.response().headers().set("Access-Control-Allow-Origin", "*");
        ctx.next();
    });
    router.post("/ping").handler((RoutingContext ctx) {
        log.info("Got requst ``ctx```");
        ctx.request().bodyHandler((Buffer buf) {
            value json = buf.toJsonObject();
            ctx.response().setChunked(true);
            ctx.response().headers().set("Content-type", "text/plain;charset=UTF-8");
            value proc = Process.create(vertx, "ping", args("-W", "3", "-c", "1", json.getString("host")));
            proc.start((proc) {
                log.debug("Proc started");
            });
            proc.stderr().exceptionHandler((Throwable t) {
                log.error("ERR Exception", t);
            });
            proc.stderr().handler((Buffer buf) {
                log.error(buf.toString("UTF-8"));
            });
            proc.stdout().exceptionHandler((Throwable t) {
                log.error("OUT Exception", t);
            });
            proc.stdout().handler((Buffer buf) {
                log.debug("Data ``buf.toString("UTF-8")``");
                ctx.response().write(buf);
            });
            proc.exitHandler((JInteger exitValue) {
                log.debug("Exited ``exitValue``");
                ctx.response().end();
            });
        });
    });
}
