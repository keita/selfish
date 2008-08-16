class Numeric
  include Selfish::ObjectInterface
  def max(x)
    self > x ? self : x
  end
end
