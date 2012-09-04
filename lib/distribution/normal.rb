require 'distribution/normal/ruby'
require 'distribution/normal/gsl'
require 'distribution/normal/statistics2'
require 'distribution/normal/java'

module Distribution
  # From Wikipedia: 
  #   Continuous probability distribution that is often used as 
  #   a first approximation to describe real-valued random variables 
  #   that tend to cluster around a single mean value. 
  #   The graph of the associated probability density function is  “bell”-shaped
  module Normal
    SHORTHAND='norm'
    extend Distributable
    
    create_distribution_methods
    
    ##
    # :singleton-method: pdf(x)
    # Returns PDF of Normal distribution 

    ##
    # :singleton-method: p_value(qn)
    # Return the P-value of the corresponding integral +qn+
    
    ##
    # :singleton-method: cdf(x)
    # Returns the integral of Normal distribution over [0, +x+]
    
    ##
    # :singleton-method: rng
    # Returns a lambda which returns a random number from
    # X ~ N(0,1)

    Bandwidth = 2, 
    Sigmas = 3, 
    MeshCount = 1e4
    ## 
    # :singleton-method: kde
    # Accepts a single member array plus optional additional information
    # Returns a two member array, [x_vals,y_vals] representing the kde
    def kde(arr, bw = Bandwidth, sigmas = SIGMAS, sampling_density = MeshCount)
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
      output.transpose
    end
  end
end
