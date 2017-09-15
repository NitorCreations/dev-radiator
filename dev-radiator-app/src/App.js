import React, { Component } from 'react';
import './App.css';

class Ping extends Component {
  constructor() {
    super();
    this.state = { data: "-" };
  }

  componentDidMount() {
    this.execute();
  }

  render() {
    return <pre>{this.state.data}</pre>
  }

  execute() {
    fetch('http://localhost:4333/ping').then((response) => response.text())
      .then((data) => {
        console.log("THIS", this, data);
        this.setState({data});
        setTimeout(this.execute.bind(this), 5000);
      });
  }
}

class App extends Component {
  render() {
    return (
      <div className="App">
        <Ping/>
      </div>
    );
  }
}

export default App;
