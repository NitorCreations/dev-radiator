import ceylon.file {
    parsePath,
    File
}
import ceylon.interop.java {
    javaClass,
    javaClassFromInstance
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
import io.vertx.core.buffer {
    Buffer
}
import io.vertx.core.http {
    ...
}
import io.vertx.core.streams {
    ReadStream,
    WriteStream
}
import io.vertx.ext.web {
    Router,
    RoutingContext
}

import java.lang {
    JString=String,
    System,
    Void,
    RuntimeException
}
import java.util {
    Arrays
}
import java.util.\ifunction {
    Supplier
}

import org.apache.logging.log4j {
    LogManager,
    Level,
    Log4jLogger=Logger,
    Marker,
    MarkerManager
}
import org.jboss.modules {
    JBModule = Module
}
import org.jboss.modules.log {
    StreamModuleLogger
}
import ceylon.language.meta.declaration {
    Import,
    CModule = Module
}
import ceylon.language.meta {
    modules
}
import ceylon.collection {
    MutableList,
    ArrayList,
    HashSet,
    MutableSet
}

shared Integer serverIdleTimeout = 300000;
shared Integer listenPort = 4333;

Logger log = logger(`package`);

"Run the module `io.nitor.devopsradiator`."
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
    //logger = LogManager.hgetLogger(javaClass<NitorBackend>());
}

shared class MyVerticle() extends AbstractVerticle() {
    shared actual void start() {
        log.info("Verticle starting..");

        value router = Router.router(vertx);

        router.route().handler(object satisfies Handler<RoutingContext> {
            shared actual void handle(RoutingContext ctx) {
                log.info("Got requst ``ctx```");
                ctx.response().end("Yeah");
            }
        });

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

        log.info("Startup initialized.");
    }
}
