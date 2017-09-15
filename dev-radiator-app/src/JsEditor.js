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
      code: "function foo(t) {\n  return (Math.sin(t*10000) + Math.sin(t*1000) + Math.sin(t*100) + Math.sin(t*10) + Math.sin(t) + Math.sin(t/10) + Math.sin(t/100) + Math.sin(t/1000)) / 16 + 0.5;\n}\n\nfunction SinFeedProvider() {\n}\n\nSinFeedProvider.prototype.schedule = function(min, max, samples, resolution, cb) {\n  console.log(\"SIN\", min, max, samples, resolution);\n  var handle = setTimeout(function() {\n    var keys = [];\n    var values = [];\n    for (var i=0; i<samples; ++i) {\n      var key = min + (max - min) * i / (samples - 1);\n      keys.push(key);\n      values.push(foo(key));\n    }\n    cb({\n      startTime: min,\n      endTime: max,\n      keys: keys,\n      values: values,\n      resolution: resolution, \n      valueMins: undefined,\n      valueMaxs: undefined,\n      isExact: function(idx, origIdx) { return false; }\n    });\n  }, 900);\n  return handle;\n};\n\nreturn SinFeedProvider;\n",
      cursorRow: 0,
      cursorCol: 0,
      eol: 0
    };
  }

  render() {
    return (
      <div>
        <h1 onClick={this.onClickRun.bind(this)} className="button">Run code</h1>
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
