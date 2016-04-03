module.exports = {
    output: {
        path: 'builds',
        filename: 'builds.js'
    },
    module: {
        loaders: [
            {
                test: /\.xjs$/,
                exclude: /node_modules/,
                loaders: ['babel?presets[]=es2015', 'jst', 'xjs']
            }
        ]
    }
};
