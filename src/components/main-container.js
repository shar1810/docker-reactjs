import React, { Component } from 'react';
import _ from 'lodash';
import Card from './card';
import axios from 'axios';

export default class MainContainer extends Component {
  constructor() {
    super();

    this.state = {
      coins: [],
    };

    this.url =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd';

    this.headers = {
      'content-type': 'application/json',
      accept: 'application/json',
    };

    this.options = {
      headers: this.headers,
      timeout: 5000,
    };
  }

  getData() {
    axios
      .get(this.url, this.options)
      .then((result) => {

        console.log(result.data);

        // Convert CoinGecko response
        // into old app compatible format
        const coins = result.data.slice(0, 12).map((coin) => ({
          currency: coin.symbol.toUpperCase(),
          last: coin.current_price,
          yesterday_last: coin.high_24h,
          volume: coin.total_volume,
        }));

        this.setState({ coins });
      })
      .catch((error) => {
        console.log('API ERROR:', error);
      });
  }

  timer() {
    this.getData();
  }

  componentDidMount() {
    this.intervalId = setInterval(this.timer.bind(this), 10000);

    this.getData();
  }

  componentWillUnmount() {
    clearInterval(this.intervalId);
  }

  renderCoinCard() {
    return _.map(this.state.coins, (coin) => {
      return <Card key={coin.currency} coin={coin} />;
    });
  }

  render() {
    return (
      <div className="container">
        <div className="row">
          <div className="col s12">
            <div className="section">
              <h3 className="header">
                Cryptocurrency Monitor
              </h3>
            </div>
          </div>
        </div>

        <div className="row">
          {this.state.coins.length > 0 &&
            this.renderCoinCard()}
        </div>
      </div>
    );
  }
}
