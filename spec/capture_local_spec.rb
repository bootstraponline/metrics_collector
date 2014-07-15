require_relative 'helper'

module MetricCollector
  describe CaptureLocal do
    it :phantomas_median do
      median = CaptureLocal.phantomas_median url: 'http://www.google.com/', runs: 2

      expect(median.class).to eq(Float)
      expect(median).to be > 100
    end
  end
end