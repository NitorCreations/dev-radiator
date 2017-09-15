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
import ceylon.file {
    parsePath,
    File
}
import ceylon.logging {
    logger,
    Logger,
    addLogWriter,
    defaultPriority,
    trace,
    Priority,
    Category,
    info,
    debug,
    warn,
    error,
    fatal
}

import io.vertx.core {
    ...
}
import io.vertx.core.http {
    ...
}
import io.vertx.ext.web {
    Router
}

import java.lang {
    JString=String,
    System
}

import org.apache.logging.log4j {
    LogManager,
    Level
}

shared Integer serverIdleTimeout = 300000;
shared Integer listenPort = 4333;

Logger log = logger(`package`);

"Run the module `io.nitor.devradiator.server`."
shared void main() {
    //JBModule.moduleLogger = StreamModuleLogger(System.\ierr);
    setupLogging();
    log.info("Starting..");

    // TODO timeouts
    // TODO test responses without body e.g. 204
    value myVertx = Vertx.vertx();
    value verticle = MyVerticle();
    myVertx.exceptionHandler((e) {
        log.error("Fallback exception handler got", e);
    });

    myVertx.deployVerticle(verticle, DeploymentOptions(), object satisfies Handler<AsyncResult<JString>> {
        shared actual void handle(AsyncResult<JString> ar) {
            if (ar.succeeded()) {
                log.info("Verticle deployed, deployment id is: ``ar.result()``");
            } else {
                log.error("Verticle deployment failed!", ar.cause());
            }
        }
    });
}

void setupLogging() {
    addLogWriter((Priority priority, Category category, String message, Throwable? throwable) {
        value logger = LogManager.getLogger(category.string);
        value level = switch(priority) case(trace) Level.trace case(debug) Level.debug case(info) Level.info case(warn) Level.warn case(error) Level.error case(fatal) Level.fatal else Level.info;
        if (logger.isEnabled(level)) {
            logger.log(level, message, throwable);
        }
    });
    defaultPriority = trace;
    value filePath = parsePath("log4j2.xml");
    if (filePath.resource is File) {
        System.setProperty("log4j.configurationFile", "log4j2.xml");
    }
    System.setProperty("java.util.logging.manager", "org.apache.logging.log4j.jul.LogManager");
    System.setProperty("vertx.logger-delegate-factory-class-name", "io.vertx.core.logging.Log4j2LogDelegateFactory");
    //logger = LogManager.getLogger(javaClass<NitorBackend>());
}

shared class MyVerticle() extends AbstractVerticle() {
    shared actual void start() {
        log.info("Verticle starting..");

        value router = Router.router(vertx);

        setupRoutes(vertx, router);

        listen(router);

        log.info("Startup initialized.");
    }

    void listen(Router router) {
        vertx.createHttpServer(HttpServerOptions()
        // .setHandle100ContinueAutomatically(false)
            .setReuseAddress(true)
            .setCompressionSupported(true)
            .setUsePooledBuffers(true)
            .setIdleTimeout(serverIdleTimeout)
        )
            .requestHandler(router.accept)
            .listen(listenPort, object satisfies Handler<AsyncResult<HttpServer>> {
            shared actual void handle(AsyncResult<HttpServer> ar) {
                if (ar.succeeded()) {
                    log.info("HTTP started on port ``listenPort``, sample public url: http://localhost:``listenPort``/");
                } else {
                    log.error("HTTP failed on port ``listenPort``", ar.cause());
                }
            }
        });
    }
}
