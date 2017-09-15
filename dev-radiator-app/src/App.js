import React, {Component} from 'react';
import './App.css';

class Ping extends Component {
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

class App extends Component {
  render() {
    return (
      <div className="App">
        <Ping label="TKK" host="www.hut.fi"/>
        <Ping label="google dns" host="8.8.8.8"/>
      </div>
    );
  }
}

export default App;
