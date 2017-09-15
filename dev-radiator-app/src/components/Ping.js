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
