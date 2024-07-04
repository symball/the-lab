// const fz = require('zigbee-herdsman-converters/converters/fromZigbee');
// const ts = require('zigbee-herdsman-converters/converters/toZigbee');
// const exposes = require('zigbee-herdsman-converters/lib/exposes');
// const reporting = require('zigbee-herdsman-converters/lib/reporting');
// const extend = require('zigbee-herdsman-converters/lib/extend');
// const e = exposes.presets;
// const ea = exposes.access;

const {light} = require('zigbee-herdsman-converters/lib/modernExtend');
module.exports = {
    zigbeeModel: ['AD-GU10RGBW3001'],
    model: '81895',
    vendor: 'AduroSmart',
    description: 'ERIA GU10 Tunable Color',
    // Note that fromZigbee, toZigbee, exposes (and more) are missing here since we use modern extend.
    // Modern extends contain all of them and are the preferred way of supporting new devices.
    extend: [
        light({colorTemp: {range: undefined}, color: true}),
    ],
    // extend: extend.light_onoff_brightness_colortemp_color({colorTempRange: [153, 500]}),
};