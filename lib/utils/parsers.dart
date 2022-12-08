class Parser {
  static parseAddress(address) {
    if (address.startsWith('monero:')) {
      var uri = Uri.parse(address);
      // Extract the amount and description from the URI
      var amount = uri.queryParameters["tx_amount"];
      var spendAddress = uri.path;
      var description = uri.queryParameters["tx_description"];
      return [spendAddress, amount, description];
    }
    return [address, null, null];
  }
}
