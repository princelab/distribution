test_arr = [28.0,596.0,494.0,38.0,717.0,47.0,51.0,891.0,411.0,22.0,31.0,566.0,30.0,556.0,35.0,443.0,23.0,523.0,556.0,30.0,882.0,53.0,455.0,34.0,463.0,24.0]
# A normal distribution generator?  Why is it skewed?
# test_arr = 10000.times.map { rand }
$LOAD_PATH << "lib"
require 'distribution'
distance = 1
# Value is distance from datapoint
Distribution::Normal.pdf(distance)


MeshCount = 9200 

Sigmas = 300

Bandwidth = 100

def nrd0(inputArray, stdDeviation) 
  bandwidth = ((4 * stdDeviation ** 5)/(3 * inputArray.size))**(1.0/5)
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

norm = []
five = []
three = []
ten = []

(-10..10).step(0.01) do |i|
   norm << [i, Distribution::Normal.custom_pdf(i)]
   five << [i, Distribution::Normal.custom_pdf(i, 5)]
   three << [i, Distribution::Normal.custom_pdf(i, 3)]
   ten << [i, Distribution::Normal.custom_pdf(i, 10)]
end



require 'gnuplot'
=begin
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
