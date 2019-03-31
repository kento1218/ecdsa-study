require "./galois_field"
require "./elliptic_curve"

module ECDSA
  Curve = EllipticCurve.new(
    GaloisField.new(0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF),
    0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC,
    0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B
  )
  G = Curve.point(
    0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296,
    0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5
  )
  N = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551

  class Key
    def initialize(priv = nil)
      if priv.nil?
        priv = rand(1...N)
      end
      raise if priv < 1 || priv >= N

      gf = GaloisField.new(N)
      @priv = gf.element(priv)
      @pub = G.scholar(priv)
    end

    def sign(message, k = nil)
      if k.nil?
        k = rand(1...N)
      end

      gf = GaloisField.new(N)
      k = gf.element(k)
      m = gf.element(message)

      p0 = G.scholar(k)
      raise if p0.x.to_i == 0

      r = gf.element(p0.x.to_i)
      s = (m + r * @priv) / k

      return [r.to_i, s.to_i]
    end

    def pub
      return [@pub.x.to_i, @pub.y.to_i]
    end
  end

  def self.verify(message, px, py, r, s)
    raise if r < 1 || r >= N
    raise if s < 1 || s >= N

    pub = Curve.point(px, py)

    gf = GaloisField.new(N)
    r = gf.element(r)
    s = gf.element(s)
    m = gf.element(message)

    w = s.inv
    u1 = m * w
    u2 = r * w

    p1 = G.scholar(u1) + pub.scholar(u2)

    return p1.x.to_i == r.to_i
  end
end
