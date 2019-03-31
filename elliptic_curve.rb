require "./galois_field"

# 有限体 gf 上の楕円曲線 y^2 = x^3 + ax + b の点とその演算を表すクラス
class EllipticCurve

  module PointMixin
    attr_reader :curve

    def +(pt)
      @curve.add(self, pt)
    end
    def scholar(n)
      @curve.scholar(n, self)
    end
  end

  class InfinityPoint
    def initialize(curve)
      @curve = curve
    end

    def infinity?
      true
    end
    def ==(pt)
      pt.infinity?
    end

    def x
      raise
    end
    def y
      raise
    end

    include PointMixin
  end

  class Point
    def initialize(curve, x, y)
      @curve = curve
      @x = x
      @y = y
    end

    attr_reader :x, :y

    def ==(pt)
      !pt.infinity? && @curve == pt.curve && x == pt.x && y == pt.y
    end

    def infinity?
      false
    end

    include PointMixin
  end

  def initialize(gf, a, b)
    @gf = gf
    @a = gf.element(a)
    @b = gf.element(b)
  end

  attr_reader :gf, :a, :b

  def point(x, y)
    pt = Point.new(self, gf.element(x), gf.element(y))
    raise unless includes?(pt)
    return pt
  end

  def infinity
    InfinityPoint.new(self)
  end

  def ==(curve)
    curve.gf == @gf && curve.a == @a && curve.b == @b
  end

  def includes?(pt)
    pt.infinity? || (pt.y * pt.y == pt.x * pt.x * pt.x + pt.x * a + b)
  end

  def add(p0, p1)
    return p1 if p0.infinity?
    return p0 if p1.infinity?
    if p0.x == p1.x && (p0.y + p1.y) == gf.element(0)
      return InfinityPoint.new(self)
    end
    u = p0.x == p1.x \
      ? (p0.x * p0.x * gf.element(3) + a) / (p0.y * gf.element(2)) \
      : (p0.y - p1.y) / (p0.x - p1.x)
    x = u * u - p0.x - p1.x
    y = (p0.x - x) * u - p0.y
    return Point.new(self, x, y)
  end

  def scholar(n, pt)
    raise unless n.respond_to?(:to_i)
    n = n.to_i
    res = InfinityPoint.new(self)
    pow = Point.new(self, pt.x, pt.y)
    while (n > 0)
      if (n % 2 == 1)
        res = res + pow
      end
      n /= 2
      pow = pow + pow
    end
    return res
  end
end
