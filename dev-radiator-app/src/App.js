import React, {Component} from 'react';
import './App.css';
import Ping from './Ping';
import JsEditor from './JsEditor';

class App extends Component {
  render() {
    return (
      <div className="App">
        <Ping label="TKK" host="www.hut.fi"/>
        <Ping label="google dns" host="8.8.8.8"/>
        <JsEditor/>
      </div>
    );
  }
}

export default App;
