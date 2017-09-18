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
import './App.css';
import Ping from './components/Ping';
import JsEditor from './JsEditor';
//import foo from './components/*.js';
import path from 'path';
import _ from 'underscore';
import RemoteFetch from './components/RemoteFetch';

const components = {
  Ping: {
    component: Ping,
    defaultProps: {label: "googl", host: "www.google.fi"},
  },
  RemoteFetch: {
    component: RemoteFetch,
    defaultProps: {label: "test", url: "http://localhost:3000/", expectedContent: /success/, expectedStatus: 200},
  },
};

class App extends Component {
  constructor() {
    super();
    this.state = {
      list: [],
    };
  }

  render() {
    return (
      <div className="App">
        {this.state.list.map(entry => React.createElement(entry.component, entry.props))}
        {/*
        <Ping label="TKK" host="www.hut.fi"/>
        <Ping label="google dns" host="8.8.8.8"/>
        */}
        <form action="javascript:void(0)">
          <select onChange={this.onChange.bind(this)} ref={ref => this.select = ref}>
            <option value="">Add new..</option>
            {_.keys(components).map(key => <option>{key}</option>)}
          </select>
          <div style={{display: this.select && this.select.value.length ? "block" : "none" }}>
            <textarea ref={ref => this.propsEditor = ref} cols="50" rows="6"/>
            <button onClick={this.onClick.bind(this)}>Add</button>
          </div>
        </form>
        <hr/>
        <JsEditor/>
      </div>
    );
  }

  onChange() {
    const component = this.select.value;
    if(component === '') {
      this.propsEditor.value = "";
    } else {
      this.propsEditor.value = JSON.stringify(components[component].defaultProps, null, "  ");
    }
    this.setState({component});
  }

  onClick() {
    const component = this.select.value;
    const props = this.propsEditor.value;
    console.log({ component, props: JSON.parse(props) });
    const newList = [
      ...this.state.list,
      {
        component: components[component].component,
        props: JSON.parse(props)
      }
    ];
    this.setState({list: newList});
    this.select.value = '';
    this.propsEditor.value = '';
  }
}

export default App;
