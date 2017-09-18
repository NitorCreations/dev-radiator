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

export default class Ping extends Component {
  constructor() {
    super();
    this.state = {
      data: "n/a",
    };
  }

  componentDidMount() {
    this.execute();
  }

  render() {
    const na      = "n/a" === this.state.data;
    const success = / \d+ received/.test(this.state.data);
    return <div className="signal">
      <p>
        <span className={"signal " + (na ? "signal-unknown" : success ? "signal-green" : "signal-red")}/>
        <span className="signal-label">{this.props.label}</span>
      </p>
      {!na && <pre className="onhover">{this.state.data}</pre>}
    </div>;
  }

  execute() {
    fetch('http://localhost:4333/ping', {
      cache: 'no-cache',
      method: 'POST',
      body: JSON.stringify(
        {
          host: this.props.host,
        }),
    }).then(response => response.text())
      .then(data => {
        this.setState({data});
        setTimeout(this.execute.bind(this), 5000);
      }).catch(err => {
      this.setState({data: "n/a"});
    });
  }
}

Ping.propTypes = {
  label: React.PropTypes.string.isRequired,
  host: React.PropTypes.string.isRequired,
};
