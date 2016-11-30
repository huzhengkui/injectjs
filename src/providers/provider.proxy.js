/*exported ProviderProxy*/
function createProviderProxyPrototype(stores, providers) {
    'use strict';
    if (!stores) {
        throw new TypeError("no stores object passed.");
    }

    if (!providers) {
        throw new TypeError("no providers object passed.");
    }


    providers.base = {
        $get: function () { throw 'not implemented'; },
        _instantiate: function () { throw 'not implemented'; }
    };

    providers.transient = Object.create(providers.base);
    providers.singleton = Object.create(providers.base);
    providers.state = Object.create(providers.base);
    providers.root = Object.create(providers.base);
    providers.parent = Object.create(providers.base);

    return {
        $get: function () { throw 'not implemented'; }
    };
}