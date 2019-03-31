require "minitest/autorun"
require "./util"
require "./galois_field"
require "./elliptic_curve"
require "./ecdsa"

class UtilTest < MiniTest::Test
  def test_egcd
    assert_equal([1, 30127, -3719], Util.egcd(12357, 100102))
  end
end

class GaloisTest < MiniTest::Test
  def setup
    @gf = GaloisField.new(13)
  end

  def test_add
    a = @gf.element(7)
    b = @gf.element(11)
    c = @gf.element(5)
    assert_equal(c, a + b)
    assert_equal(c, b + a)
  end

  def test_mul
    a = @gf.element(7)
    b = @gf.element(2)
    c = @gf.element(1)
    assert_equal(c, a * b)
    assert_equal(c, b * a)
  end

  def test_equal
    assert(@gf == GaloisField.new(13))
    assert(@gf != GaloisField.new(17))
    assert(@gf.element(7) == @gf.element(7))
    assert(@gf.element(7) != @gf.element(11))
  end

  def test_neg
    a = @gf.element(7)
    b = @gf.element(6)
    assert_equal(a, -b)
  end

  def test_sub
    a = @gf.element(7)
    b = @gf.element(11)
    c = @gf.element(9)
    assert_equal(c, a - b)
  end

  def test_inv
    a = @gf.element(7)
    b = @gf.element(2)
    assert_equal(a, b.inv)
  end
end

class EllipticCurveTest < MiniTest::Test
  def setup
    # NIST-P256 の曲線パラメータを使用
    @curve = EllipticCurve.new(
      GaloisField.new(0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF),
      0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC,
      0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B
    )

    # NIST-P256 のベースポイントのスカラ倍点をケースに使用
    @p1 = @curve.point(
      0x6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296,
      0x4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5
    )
    @p2 = @curve.point(
      0x7CF27B188D034F7E8A52380304B51AC3C08969E277F21B35A60B48FC47669978,
      0x07775510DB8ED040293D9AC69F7430DBBA7DADE63CE982299E04B79D227873D1
    )
    @p3 = @curve.point(
      0x5ECBE4D1A6330A44C8F7EF951D4BF165E6C6B721EFADA985FB41661BC6E7FD6C,
      0x8734640C4998FF7E374B06CE1A64A2ECD82AB036384FB83D9A79B127A27D5032
    )
    @p5 = @curve.point(
      0x51590B7A515140D2D784C85608668FDFEF8C82FD1F5BE52421554A0DC3D033ED,
      0xE0C17DA8904A727D8AE1BF36BF8A79260D012F00D4D80888D1D0BB44FDA16DA4
    )
    # k = 112233445566778899
    @pk = @curve.point(
      0x339150844EC15234807FE862A86BE77977DBFB3AE3D96F4C22795513AEAAB82F,
      0xB1C14DDFDC8EC1B2583F51E85A5EB3A155840F2034730E9B5ADA38B674336A21
    )
  end

  def test_add
    assert_equal(@p5, @p2 + @p3)
    assert_equal(@p5, @p3 + @p2)

    assert_equal(@p2, @p2 + @curve.infinity)
    assert_equal(@p2, @curve.infinity + @p2)
  end

  def test_scholar
    assert_equal(@p3, @p1.scholar(3))
    assert_equal(@pk, @p1.scholar(112233445566778899))
  end

  def test_scholar_circular
    n = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551
    assert_equal(@curve.infinity, @p1.scholar(0))
    assert_equal(@curve.infinity, @p1.scholar(n))
  end

  def test_include
    assert(!@curve.includes?(EllipticCurve::Point.new(
      @curve, @curve.gf.element(0), @curve.gf.element(0)
    )))
    assert_raises { @curve.point(0, 0) }
  end

  def test_equal
    p1a = @curve.point(@p1.x.to_i, @p1.y.to_i)
    assert(p1a == @p1)
    assert(@p1 == p1a)
    assert(@p2 != @p1)
    assert(@curve.infinity == @curve.infinity)
  end
end

class ECDSATest < MiniTest::Test
  def setup
    # NIST のテストベクターを使用;  http://csrc.nist.gov/groups/STM/cavp/documents/components/186-3ecdsasiggencomponenttestvectors.zip
    @message = 0x44acf6b7e36c1342c2c5897204fe09504e1e2efb1a900377dbc4e7a6a133ec56
    @d = 0x519b423d715f8b581f4fa8ee59f4771a5b44c8130b4e3eacca54a56dda72b464
    @k = 0x94a1bbb14b906a61a280f245f9e93c7f3b4a6247824f5d33b9670787642a68de
    @px = 0x1ccbe91c075fc7f4f033bfa248db8fccd3565de94bbfb12f3c59ff46c271bf83
    @py = 0xce4014c68811f9a21a1fdb2c0e6113e06db7ca93b7404e78dc7ccd5ca89a4ca9
    @r = 0xf3ac8061b514795b8843e3d6629527ed2afd6b1f6a555a7acabb5e6f79c8c2ac
    @s = 0x8bf77819ca05a6b2786c76262bf7371cef97b218e96f175a3ccdda2acc058903
  end

  def test_sign
    key = ECDSA::Key.new(@d)
    px, py = key.pub
    r,s = key.sign(@message, @k)

    assert_equal(px, @px)
    assert_equal(py, @py)
    assert_equal(r, @r)
    assert_equal(s, @s)
  end

  def test_verify
    result = ECDSA.verify(@message, @px, @py, @r, @s)
    assert(result)
  end
end
