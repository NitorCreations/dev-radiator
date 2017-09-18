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
import CodeMirror from 'codemirror';
import 'codemirror/lib/codemirror.css';
import 'codemirror/addon/hint/show-hint';
import 'codemirror/addon/hint/show-hint.css';
import 'codemirror/addon/hint/javascript-hint';
import 'codemirror/mode/javascript/javascript';

export default class JsEditor extends Component {
  constructor() {
    super();
    this.state = {
      code: "import React, {Component} from 'react';\n\nexport default class Ping extends Component {\n  constructor() {\n    super();\n    this.state = {\n      data: \"n/a\",\n    };\n  }\n\n  componentDidMount() {\n    this.execute();\n  }\n\n  render() {\n    const na      = \"n/a\" === this.state.data;\n    const success = / \\d+ received/.test(this.state.data);\n    return <div className=\"signal\">\n      <p>\n        <span className={\"signal \" + (na ? \"signal-unknown\" : success ? \"signal-green\" : \"signal-red\")}/>\n        <span className=\"signal-label\">{this.props.label}</span>\n      </p>\n      {!na && <pre className=\"onhover\">{this.state.data}</pre>}\n    </div>;\n  }\n\n  execute() {\n    fetch('http://localhost:4333/ping', {\n      cache: 'no-cache',\n      method: 'POST',\n      body: JSON.stringify(\n        {\n          host: this.props.host,\n        }),\n    }).then(response => response.text())\n      .then(data => {\n        this.setState({data});\n        setTimeout(this.execute.bind(this), 5000);\n      }).catch(err => {\n      this.setState({data: \"n/a\"});\n    });\n  }\n}\n",
      cursorRow: 0,
      cursorCol: 0,
      eol: 0
    };
  }

  render() {
    return (
      <div>
        <h3 onClick={this.onClickRun.bind(this)} className="button">Run code</h3>
        <div className="editor" ref={ref => this.myEditor = ref}/>
        <div className="editor">
          L{this.state.cursorRow + 1} C{this.state.cursorCol}
        </div>
        <h2>Output:</h2>
        <div className="editor">
          {this.state.output}
        </div>
      </div>
    );
  }

  onClickRun() {
    var code   = this.editor.getValue();
    var result = eval("var o,e; try { o = (function(){ " + code + "})(); } catch(ex) { e=ex; } [o,e];");
    if (result[1] !== undefined) {
      this.setState({code: code, output: "Line " + result[1].lineNumber + ": " + result[1].message});
    } else {
      this.setState({code: code, output: "<scheduled>"});
      console.log(result[0]);
      var obj = new result[0]();
      obj.schedule(1, 10, 10, 1, function scheduleCb(e) {
        var str = "";
        for (var i = 0; i < e.keys.length; ++i) {
          str += e.keys[i] + ": " + e.values[i] + "\n";
        }
        //str = JSON.stringify(e);
        this.setState({output: str});
      }.bind(this));
    }
    //console.log("after yeah", output);
  }

  componentDidMount() {
    this.editor = CodeMirror(this.myEditor, {
      value: this.state.code,
      mode: {name: "javascript", globalVars: true},
      lineNumbers: true,
      extraKeys: {"Ctrl-Space": "autocomplete"},
      eol: 0
    });
    this.editor.on("cursorActivity", this.onCursorActivity.bind(this));
    this.editor.on("change", this.onChange.bind(this));
  }

  onChange() {
  }

  onCursorActivity() {
    var rc = this.editor.getCursor();
    this.setState({cursorRow: rc.line, cursorCol: rc.ch});
  }
}
