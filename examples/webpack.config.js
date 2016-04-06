module.exports = {
    output: {
        path: 'builds',
        filename: 'builds.js'
    },
    module: {
        loaders: [
           {
                test: /\.jst$/,
                exclude: /node_modules/,
                loaders: ['babel?presets[]=es2015', 'jst']
           },
           {
                test: /\.xjs$/,
                exclude: /node_modules/,
                loaders: ['babel?presets[]=es2015', 'jst', 'xjs']
            }
        ]
    }
};
