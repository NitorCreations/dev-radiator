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
import React, {Component} from 'react';
import URL from 'url-parse';

export default class RemoteFetch extends Component {
  constructor() {
    super();
    this.state = {
      success: null,
      response: "-",
    };
  }

  componentDidMount() {
    this.execute();
  }

  render() {
    const success = this.state.success;
    return <div className="signal">
      <p>
        <span className={"signal " + (success ? "signal-green" : success === false ? "signal-red" : "signal-unknown")}/>
        <span className="signal-label">{this.props.label}</span>
      </p>
      {this.state.response && <pre className="onhover">{this.state.response}</pre>}
    </div>;
  }

  execute() {
    const expectedStatus = this.props.expectedStatus || 200;
    const expectedContent = this.props.expectedContent;
    this.remoteFetch(this.props.url).then(res => {
      return res.text().then(resText => {
        const ok = res.status === expectedStatus && (
          typeof expectedContent === "string" ? resText === expectedContent :
            typeof expectedContent === "function" ? expectedContent(resText, res) :
              expectedContent.test(resText)); // Regex
        this.setState({
                        success: ok,
                        response: this.dumpRes(res, resText),
                      });
      });
    }).catch(err => {
      //console.log(err);
      // TODO success=null if server does not respond
      this.setState({success: false, response: "" + err});
    }).then(() => setTimeout(this.execute.bind(this), 5000));
  }

  remoteFetch(url, options) {
    options = options || {};
    const parsedUrl = new URL(url, null, false);
    const headers = options.headers || (options.headers = new Headers());
    headers.set("X-next-protocol", parsedUrl.protocol);
    headers.set("X-next-host", parsedUrl.hostname);
    headers.set("X-next-port", parsedUrl.port);
    headers.set("X-next-uri", parsedUrl.pathname + parsedUrl.query);
    options.cache = 'no-cache';
    return fetch('http://localhost:4333/remoteFetch', options); // TODO use XHR to be able to specify timeout
  }

  dumpRes(res, resText) {
    return res.status + " " + res.statusText + "\n" + this.dumpHeaders(res) + "\n" + resText;
  }

  dumpHeaders(res) {
    return "";
  }
}

RemoteFetch.propTypes = {
  label: React.PropTypes.string.isRequired,
  url: React.PropTypes.string.isRequired,
  expectedContent: React.PropTypes.any.isRequired, // TODO
  expectedStatus: React.PropTypes.number,
};
