test_arr = [28.0,596.0,494.0,38.0,717.0,47.0,51.0,891.0,411.0,22.0,31.0,566.0,30.0,556.0,35.0,443.0,23.0,523.0,556.0,30.0,882.0,53.0,455.0,34.0,463.0,24.0]
# A normal distribution generator?  Why is it skewed?
# test_arr = 10000.times.map { rand }
$LOAD_PATH << "lib"
require 'distribution'


MeshCount = 9200 

Sigmas = 300

Bandwidth = 100

def nrd0(input_arr, std_deviation = input_arr.standard_deviation) 
  bandwidth = ((4 * std_deviation ** 5)/(3 * input_arr.size))**(1.0/5)
end

module Enumerable
  # Thanks StackOverflow users!
  # http://stackoverflow.com/questions/7749568/how-can-i-do-standard-deviation-in-ruby
  def sum
    self.inject(:+)
  end
  def mean
    self.sum/self.length.to_f
  end
  alias average mean
  def sample_variance
    m = self.mean
    sum = self.inject(0){|accum, i| accum + (i-m)**2}
    sum/(self.length - 1).to_f
  end
  def standard_deviation
    Math.sqrt(self.sample_variance)
  end
end


def kde(arr, bw = Bandwidth, sigmas= Sigmas, sampling_density = MeshCount)
  # Initialization steps
  min = arr.min - bw*sigmas
  max = arr.max + bw*sigmas
  step_size = (max-min)/sampling_density.to_f
  arr.sort!
  # Step through the range
  output = (min..max).step(step_size).map do |mid|
    high_end = mid+ bw*sigmas
    lower_end = mid - bw*sigmas
    included = arr.select {|a| (lower_end..high_end).include?(a)}
    intensity = included.map {|a| Distribution::Normal.custom_pdf(a-mid, bw) }.inject(:+)
    intensity ||= 0
    [mid, intensity ]
  end
end
#test_range = (1..10).to_a+ (15..30).step(5).to_a + (40..100).step(10).to_a+ (100..1500).step(100).to_a 
#responses = test_range.map {|bw| [bw, kde(test_arr, bw)] }
#p resp

bandwidth = nrd0(test_arr, Sigmas)
resp = kde(test_arr, bandwidth)

x, y = resp.transpose

require 'k_means'
kmeans = KMeans.new(test_arr, centroids: 2)
require 'pry'
binding.pry

p test_arr.standard_deviation
p nrd0(test_arr)
p nrd0(test_arr, Sigmas)

require 'gnuplot'
=begin

norm = []
three = []
five = []
ten = []
(-10..10).step(0.01) do |i|
   norm << [i, Distribution::Normal.custom_pdf(i)]
   three << [i, Distribution::Normal.custom_pdf(i, 3)]
   five << [i, Distribution::Normal.custom_pdf(i, 5)]
   ten << [i, Distribution::Normal.custom_pdf(i, 10)]
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
    #plot.xrange "[0:1000]"
    plot.xrange "[-5:5]"
    
    plot.data << Gnuplot::DataSet.new( norm.transpose ) do |ds|
      ds.with = "lines"
      ds.title = "BW: 1"
    end

    plot.data << Gnuplot::DataSet.new( three.transpose ) do |ds|
      ds.with = "lines"
      ds.title = "BW: 3"
    end
    
    plot.data << Gnuplot::DataSet.new( five.transpose ) do |ds|
      ds.with = "lines"
      ds.title = "BW: 5"
    end

    plot.data << Gnuplot::DataSet.new( ten.transpose ) do |ds|
      ds.with = "lines"
      ds.title = "BW: 10"
    end
  end
  
end
=end
# Begins after you close the first plot
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
    #plot.xrange "[0:1000]"
    plot.xrange "[-500:1000]"
    plot.terminal 'svg'
    plot.output "bandwidthing.svg"
    plot.data << Gnuplot::DataSet.new( resp.transpose ) do |ds|
      ds.with = "lines"
      ds.title = "BW: #{bandwidth}"
    end
  end
end
