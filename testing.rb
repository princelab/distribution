val = 2
arr = [2,5,8]
require 'distribution'

resp = (-5..5).step(0.01).map do |i|
  Distribution::Normal.pdf(i)
end

p resp
