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

JList<JString> splitargs(String s) {
    value l = JArrayList<JString>();
    s.split().each((String arg) => l.add(JString(arg)));
    return l;
}

void setupRoutes(Vertx vertx, Router router) {
    router.route().handler((RoutingContext ctx) {
        log.info("Got requst ``ctx```");
        ctx.response().setChunked(true);
        value proc = Process.create(vertx, "ping", splitargs("-W 3 -c 1 www.hut.fi"));
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
}
