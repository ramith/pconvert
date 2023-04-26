import ballerinax/exchangerates;
import ramith/countryprofile;
import ballerina/log;
import ballerina/http;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string exchangeRatesApiKey = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get convert(decimal amount = 1.0, string target = "AUD", string base = "USD") returns error?|http:Ok {
        log:printInfo("new converstion request", base = base, amount = amount, target = target);

        countryprofile:Client countryprofileEp = check new (config = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        });

        countryprofile:Currency getCurrencyCodeResponse = check countryprofileEp->getCurrencyCode(code = target);
        exchangerates:Client exchangeratesEp = check new ();
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check exchangeratesEp->getExchangeRateFor(apikey = exchangeRatesApiKey, baseCurrency = base);

        decimal exchangeRate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        decimal convertedAmount = amount * exchangeRate;

        PricingInfo pricingInfo = {
            currencyCode: target,
            displayName: getCurrencyCodeResponse.displayName,
            amount: convertedAmount
        };

        return {body: pricingInfo};
    }
}

type PricingInfo record {
    string currencyCode;
    string displayName;
    decimal amount;
};
