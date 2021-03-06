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
"Default documentation for module `io.nitor.devradiator.server`."

native ("jvm")
module io.nitor.devradiator.server "1.0.0" {

    shared import maven:io.nitor.api:"backend" "1.9";

    //import maven:org.mortbay.jetty.alpn:"jetty-alpn-agent" "2.0.6";
    import maven:org.mortbay.jetty.alpn:"alpn-boot" "8.1.11.v20170118";
// -javaagent:/home/xkr47/jonas/.m2/repository/org/mortbay/jetty/alpn/jetty-alpn-agent/2.0.6/jetty-alpn-agent-2.0.6.jar
    /*
        shared import maven:com.fasterxml.jackson.datatype:"jackson-datatype-jsr310" "2.8.8";
        shared import maven:com.fasterxml.jackson.core:"jackson-databind" "2.8.8";
        shared import maven:com.fasterxml.jackson.core:"jackson-core" "2.8.8";
        shared import maven:com.fasterxml.jackson.core:"jackson-annotations" "2.8.0";
        shared import maven:org.shredzone.acme4j:"acme4j-client" "0.9";
        shared import maven:org.shredzone.acme4j:"acme4j-utils" "0.9";
    */
    shared import maven:io.vertx:"vertx-core" "3.4.1";
    shared import maven:io.vertx:"vertx-web" "3.4.1";

    import maven:com.julienviet:"childprocess-vertx-ext" "1.1.2";
/*
    import com.redhat.ceylon.model "1.3.3";
    import ceylon.runtime "1.3.3";
    import org.jboss.modules "1.4.4.Final";
*/
    import maven:org.apache.logging.log4j:"log4j-api" "2.8.2";
    import maven:org.apache.logging.log4j:"log4j-core" "2.8.2";
    import maven:org.apache.logging.log4j:"log4j-1.2-api" "2.8.2";
    import maven:org.apache.logging.log4j:"log4j-jcl" "2.8.2";
    import maven:org.apache.logging.log4j:"log4j-jul" "2.8.2";

//    import maven:org.eclipse.jetty.osgi:"jetty-osgi-alpn" "9.4.6.v20170531";

    import maven:io.netty:"netty-codec-http" "4.1.9.Final";

    import ceylon.collection "1.3.3";

    //shared import "io.vertx:vertx-lang-ceylon" "3.3.0-SNAPSHOT";
    //shared import "io.vertx.lang.ceylon" "3.3.0-SNAPSHOT";
    import ceylon.regex "1.3.3";
    import ceylon.logging "1.3.3";
    //import ceylon.time "1.2.1";
    import java.base "8";
    //import "it.zero11:acme-client" "0.1.2";
    import ceylon.file "1.3.3";
    import ceylon.buffer "1.3.3";
    import ceylon.interop.java "1.3.3";
    import ceylon.json "1.3.3";

}
