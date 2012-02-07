module.exports = {
  Command: {
    run: function() {
      console.log('Running!');
      console.log('Args:', process.argv);
    }
  }
};
