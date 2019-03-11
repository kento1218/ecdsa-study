module Util
  def self.egcd(a, b)
    # http://www.tbasic.org/reference/old/ExEuclid.html

    x0 = 0; x1 = 1
    y0 = 1; y1 = 0
    while (b > 0)
      q, nb = a.divmod(b)
      a = b
      b = nb

      nx0 = x1 - q * x0
      x1 = x0
      x0 = nx0

      ny0 = y1 - q * y0
      y1 = y0
      y0 = ny0
    end
    [a, x1, y1]
  end
end
