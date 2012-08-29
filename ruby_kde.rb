test_arr = [28.0,596.0,494.0,38.0,717.0,47.0,51.0,891.0,411.0,22.0,31.0,566.0,30.0,556.0,35.0,443.0,23.0,523.0,556.0,30.0,882.0,53.0,455.0,34.0,463.0,24.0]
# A normal distribution generator?  Why is it skewed?
# test_arr = 10000.times.map { rand }
$LOAD_PATH << "lib"
require 'distribution'
distance = 1
# Value is distance from datapoint
Distribution::Normal.pdf(distance)


MeshCount = 2200 

Sigmas = 3

Bandwidth = 1

def kde(arr, bw = Bandwidth, sigmas= Sigmas, sampling_density = MeshCount)
  # Initialization steps
  min = arr.min - bw*sigmas
  max = arr.max + bw*sigmas
  step_size = (max-min)/sampling_density.to_f
  arr.sort!
  # Step through the range
  output = (min..max).step(step_size).map do |lower_end|
    high_end = lower_end+ bw*sigmas
    included = arr.select {|a| (lower_end..high_end).include?(a)}
    intensity = included.map {|a| Distribution::Normal.custom_pdf(a-lower_end, bw) }.inject(:+)
    intensity ||= 0
    [intensity, lower_end]
  end
end

resp = kde(test_arr)
p resp

y, x = resp.transpose

(-10..10).step(2) do |i|
  p Distribution::Normal.custom_pdf(3, i)
end

require 'gnuplot'
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  
    plot.xrange "[0:1000]"
    
    plot.data << Gnuplot::DataSet.new( [x,y] ) do |ds|
      ds.with = "lines"
      ds.notitle
    end
    
  end
  
end
