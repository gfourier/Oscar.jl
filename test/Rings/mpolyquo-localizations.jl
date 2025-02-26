@testset "mpolyquo-localizations.jl" begin
  R, v = QQ["x", "y", "u", "v"]
  x = v[1]
  y = v[2] 
  u = v[3]
  v = v[4]
  f = x*v-y*u
  I = ideal(R, f)
  Q, p = quo(R, I)
  S = MPolyComplementOfKPointIdeal(R, [QQ(1), QQ(0), QQ(1), QQ(0)])
  T = MPolyComplementOfKPointIdeal(R, [QQ(0), QQ(0), QQ(0), QQ(0)])
  L, _ = localization(Q, S)
  a = L(x)
  b = L(y)
  c = L(u)
  d = L(v)
  
  kk= QQ
  R, v = kk["x", "y"]
  x = v[1]
  y = v[2] 
  f = (x^2 + y^2)
  T = MPolyComplementOfKPointIdeal(R, [kk(0), kk(0)])
  I = ideal(R, f)
  V = MPolyQuoLocRing(R, I, T)

  S = R
  U = MPolyPowersOfElement(S, [f-1])
  J = ideal(S, zero(S))
  W = MPolyQuoLocRing(S, J, U)

  h = MPolyQuoLocalizedRingHom(W, V, [x//(y-1), y//(x-5)])
  J1 = ideal(V, [x*(x-1), y*(y-3)])
  J2 = ideal(W, [x, y])
  @test preimage(h, J1) == J2
  
  ### second round of tests
  #kk = GF(101)
  ⊂ = issubset
  kk = QQ
  R, (x,y) = kk["x", "y"]

  f = x^2 + y^2-2
  S = MPolyPowersOfElement(x-1)
  T = MPolyComplementOfKPointIdeal(R, [1,1])
  V = MPolyComplementOfPrimeIdeal(ideal(R, f))
  ⊂ = issubset
  @test S ⊂ V
  @test !(V ⊂ S)
  @test !(T ⊂ V)
  @test (V ⊂ T)
  @test !(MPolyComplementOfPrimeIdeal(ideal(R, f-1)) ⊂ T)
  @test S ⊂ MPolyComplementOfPrimeIdeal(ideal(R, f-1))
  @test !(MPolyPowersOfElement(f) ⊂ V)
  @test MPolyPowersOfElement(x-1) ⊂ MPolyComplementOfKPointIdeal(R, [0,0])
  @test MPolyPowersOfElement(x-1) * MPolyComplementOfKPointIdeal(R, [0,0]) ⊂ MPolyComplementOfKPointIdeal(R, [0,0])
  @test !(MPolyPowersOfElement(x) ⊂ MPolyComplementOfKPointIdeal(R, [0,0]))
  @test T*T == T

  U = S*T
  @test U[1] ⊂ S || U[1] ⊂ T
  @test U[2] ⊂ S || U[2] ⊂ T
  @test S ⊂ U 
  @test T ⊂ U
  @test S*U == U
  @test T*U == U 
  @test U*U == U
  g = rand(S, 0:3, 1:5, 2:8)
  g = rand(T, 0:3, 1:5, 2:8)
  g = rand(U, 0:3, 1:5, 2:8)
  W, _ = localization(U)
  localization(W, S)
  @test base_ring(W) == R
  @test inverted_set(W) == U
  L, _ = quo(W, ideal(W, f))
  @test issubset(modulus(underlying_quotient(L)), saturated_ideal(modulus(L)))
  @test gens(L) == L.(gens(R))
  @test x//(y*(x-1)) in L

  I = ideal(L, (x-1)*(y-1))
  @test one(L) in I
  @test is_unit(L(y-1))

  h = x^4+23*x*y^3-15
  Q, _ = quo(R, f)
  T = MPolyPowersOfElement(h^3)
  W, _ = localization(Q, T)
  @test x//(h+3*f) in W
  @test W(x//(h+3*f)) == W(x//h)
  g = W.([rand(R, 0:5, 0:2, 0:1) for i in 1:10])
  @test isone(W(h)*inv(W(h)))
  g = [W(8*x*h+4), W(x, 45*h^2)]
  @test one(localized_ring(W)) in ideal(W, g)

  @test one(W) == dot(write_as_linear_combination(one(W), g), g)


  h = (x+5)*(x^2+10*y)+(y-7)*(y^2-3*x)
  Q, _ = quo(R, h)
  T = MPolyComplementOfKPointIdeal(R, [-5, 7])
  W, _ = localization(Q, T)
  @test x//(y) in W
  @test x//(y+h) in W
  g = [W(h + (x+5) - 9, y+24*x^3-8)]
  (d, a) = bring_to_common_denominator([one(W), g[1]])
  @test W(a[1], d) == one(W)
  @test W(a[2]*lifted_numerator(g[1]), d) == g[1]
  @test (one(localized_ring(W)) in ideal(W, g))
  @test one(W) == dot(write_as_linear_combination(one(W), g), g) 
end

@testset "prime ideals in quotient rings" begin
  R, (x, y) = QQ["x", "y"]
  I = ideal(R, [x^2-y^2])
  U = powers_of_element(y)
  A, = quo(R, I)
  L, = localization(A, U)
  J = ideal(R, [y*(x-1), y*(y+1)])
  @test !is_prime(J)
  @test is_prime(L(J))
end

@testset "additional hom constructors" begin
  R, (x, y) = ZZ["x", "y"]
  I = ideal(R, [x^2-y^2])
  U = powers_of_element(y)
  A, = quo(R, I)
  L, = localization(A, U)
  phi = hom(L, L, gens(L))
end
  
@testset "fractions and divexact: Issue #1885" begin
  R, (x, y) = ZZ["x", "y"]
  I = ideal(R, [x^2-y^2])
  U = powers_of_element(y)
  A, = quo(R, I)
  L, = localization(A, U)

  @test L(x)/L(y) == L(x//y)
  @test L(y)/L(x) == L(y//x)
  @test_throws ErrorException L(y)/L(x-1)
end

@testset "associated primes (quo and localized)" begin
  # define the rings
  R,(x,y,z,w) = QQ["x","y","z","w"]
  Q1 = ideal(R,[x^2+y^2-1])
  Q2 = ideal(R,[x*y-z*w])
  RQ1,phiQ1 = quo(R,Q1)
  RQ2,phiQ2 = quo(R,Q2)
  T1 = MPolyComplementOfKPointIdeal(R,[0,0,0,0])
  f = x+y+z+w-1
  T2 = MPolyPowersOfElement(f)
  RL1,phiL1 = localization(R,T1)
  RL2,phiL2 = localization(R,T2)
  RQ1L1, phiQ1L1 = localization(RQ1,T1)
  RQ1L2, phiQ1L2 = localization(RQ1,T2)
  RQ2L1, phiQ2L1 = localization(RQ2,T1)
  RQ2L2, phiQ2L2 = localization(RQ2,T2)

  # tests for MPolyQuoRing
  I1 = ideal(R,[x*z*(w-1),y*z*(w-1)])
  I2 = ideal(R,[y^2*x*(x+y+w-1),z])
  LM = minimal_primes(phiQ1(I1))
  LP = primary_decomposition(phiQ1(I1))  ## coincides with min. ass. primes here
  @test length(LM) == 2
  @test length(LP) == 2
  @test intersect(LM) == phiQ1(radical(I1+Q1))
  @test intersect([a for (a,_) in LP]) == intersect(LM)
  LM = minimal_primes(phiQ2(I1))
  LP = primary_decomposition(phiQ2(I1)) 
  @test length(LM) == 4
  @test intersect(LM) == phiQ2(radical(I1+Q2))
  @test length(LP) == 5
  @test intersect([a for (a,_) in LP]) == phiQ2(I1+Q2)

  # tests for MPolyLocRing
  LM = minimal_primes(phiL1(I1))   
  LP = primary_decomposition(phiL1(I1)) ## coincides with min. ass. primes here
  @test length(LM) == 2
  @test length(LP) == 2
  @test intersect(LM) == phiL1(I1)
  @test intersect([a for (a,_) in LP]) == phiL1(I1)
  LM = minimal_primes(phiL2(I2))
  LP = primary_decomposition(phiL2(I2))
  @test intersect(LM) == ideal(RL2,RL2.([z,x*y]))
  @test intersect([a for (a,_) in LP]) == ideal(RL2,RL2.([z,x*y^2]))

  # tests for MPolyLocQuoRing
  LM = minimal_primes(phiQ1L1(phiQ1(I1))) 
  @test length(LM)==0
  LM = minimal_primes(phiQ2L1(phiQ2(I1)))
  LP = primary_decomposition(phiQ2L1(phiQ2(I1)))
  @test length(LM) == 3
  @test length(LP) == 4
  @test intersect(LM) == phiQ2L1(phiQ2(radical(I1+Q2)))
  @test intersect([a for (a,_) in LP]) == phiQ2L1(phiQ2(I1+Q2))
  @test length(minimal_primes(phiQ2L1(phiQ2(I2)))) == 2
  @test length(minimal_primes(phiQ2L2(phiQ2(I2)))) == 2
end

@testset "saturation (quo and localization)" begin
  # define the rings
  R,(x,y,z) = QQ["x","y","z"]
  Q1 = ideal(R,[x])
  Q2 = ideal(R,[z,x^2-y^2])
  RQ1,phiQ1 = quo(R,Q1)
  RQ2,phiQ2 = quo(R,Q2)
  T1 = MPolyComplementOfKPointIdeal(R,[0,0,0])
  f = x-y
  T2 = MPolyPowersOfElement(f)
  RL1,phiL1 = localization(R,T1)
  RL2,phiL2 = localization(R,T2)
  RQ1L1, phiQ1L1 = localization(RQ1,T1)
  RQ1L2, phiQ1L2 = localization(RQ1,T2)
  RQ2L1, phiQ2L1 = localization(RQ2,T1)
  RQ2L2, phiQ2L2 = localization(RQ2,T2)

  # the ideals
  I1 = ideal(R,[x^2*y+y^2*z+z^2*x])
  I2 = ideal(R,[x-y])
  I3 = ideal(R,[x,y,z])
  I4 = ideal(R,[x-1,y-1,z])
  I5 = ideal(R,[x,y+1,z-1])
  I6 = ideal(R,[y])

  # quotient ring tests
  I = phiQ1(I1)
  J = phiQ1(I6)
  @test saturation_with_index(I,J)[2] == 2
  K = phiQ1(I2*I3*I4*I5)
  @test saturation(K,J) == phiQ1(I5)
  I = phiQ2(I1)
  J = phiQ2(I6)
  @test saturation_with_index(I,J)[2] == 3
  K = phiQ2(I2*I3*I4*I5)
  @test saturation(K,J) == phiQ2(I2*I4)

  # localized ring tests
  I = phiL1(I1)
  J = phiL1(I6)
  @test saturation_with_index(I,J)[2] == 0
  K = phiL1(I2*I3*I4*I5)
  @test saturation(K,J) == phiL1(I2)
  I = phiL2(I1*I6^2)
  J = phiL2(I6)
  @test saturation_with_index(I,J)[2] == 2
  K = phiL2(I2*I3*I4*I5)
  @test saturation(K,J) == phiL2(I5)

  # localized quo ring tests
  I = phiQ1L1(phiQ1(I1))
  J = phiQ1L1(phiQ1(I6))
  @test saturation_with_index(I,J)[2] == 2
  K = phiQ1L1(phiQ1(I2*I3*I4*I5))
  @test saturation(K,J) == ideal(RQ1L1,one(RQ1L1))
  @test saturation_with_index(K,J)[2] == 2
  I = phiQ1L2(phiQ1(I1))
  J = phiQ1L2(phiQ1(I6))
  @test saturation(I,J) == phiQ1L2(phiQ1(ideal(R,[x,z])))
  K = phiQ1L2(phiQ1(I2*I3*I4*I5))
  @test saturation(K,J) == phiQ1L2(phiQ1(ideal(R,[z - 1, y + 1])))
  I = phiQ2L1(phiQ2(I1))
  J = phiQ2L1(phiQ2(I6))
  @test saturation_with_index(I,J)[2] == 3
  K = phiQ2L1(phiQ2(I2*I3*I4*I5))
  @test saturation(K,J) == phiQ2L1(phiQ2(ideal(R,[x-y])))
end

@testset "algebras as vector spaces" begin
  R, (x,y) = QQ["x", "y"]
  I = ideal(R, [x^3- 2, y^2+3*x])
  I = (x-8)^2*I
  L, _ = localization(R, powers_of_element(x-8))
  A, pr = quo(L, L(I))
  V, id = vector_space(QQ, A)
  @test dim(V) == 6
  @test id.(gens(V)) == A.([x^2*y, x*y, y, x^2, x, one(x)])
  f = (x*3*y-4)^5
  f = A(f)
  @test id(preimage(id, f)) == f
  v = V[3] - 4*V[5]
  @test preimage(id, id(v)) == v

  R, (x,y) = QQ["x", "y"]
  I = ideal(R, [x^3, (y-1)^2+3*x])
  I = (x-8)^2*I
  L, _ = localization(R, complement_of_point_ideal(R, [0, 1]))
  A, pr = quo(L, L(I))
  V, id = vector_space(QQ, A)
  @test dim(V) == 6
  f = (x*3*y-4)^5
  f = A(f)
  @test id(preimage(id, f)) == f
  v = V[3] - 4*V[5]
  @test preimage(id, id(v)) == v
end

@testset "minimal and small generating sets" begin
  R, (x,y,z) = QQ["x","y","z"]
  IQ = ideal(R,[x-z])
  U1 = MPolyComplementOfKPointIdeal(R,[0,0,0])
  U2 = MPolyComplementOfKPointIdeal(R,[1,1,1])
  U3 = MPolyPowersOfElement(y)
  Q1 = MPolyQuoLocRing(R,IQ,U1)
  Q2 = MPolyQuoLocRing(R,IQ,U2)
  Q3 = MPolyQuoLocRing(R,IQ,U3)
  J1 = ideal(Q1,[x^2-y^2,y^2-z^2,x^2-z^2])
  @test length(minimal_generating_set(J1)) == 1
  @test length(small_generating_set(J1)) == 1
  @test ideal(Q1, small_generating_set(J1)) == ideal(Q1, minimal_generating_set(J1))
  @test ideal(Q1, minimal_generating_set(J1)) == J1

  J2 = ideal(Q2,[x^2-y^2,y^2-z^2,x^2-z^2])
  @test length(minimal_generating_set(J2)) == 1
  @test ideal(Q2, minimal_generating_set(J2)) == J2
  J3 = ideal(Q3,[x^2-z^2,y*(y-1)])
  @test length(small_generating_set(J3)) == 1
  @test ideal(Q3,small_generating_set(J3)) == J3

  R, (x, y) = QQ[:x, :y]
  I = ideal(R, x^6-y)
  U = complement_of_point_ideal(R, [1, 1])
  L = MPolyQuoLocRing(R, I, U)
  J = ideal(L, [x-1, y-1])^2
  minJ = minimal_generating_set(J)
  @test length(minJ) == 1
  @test ideal(L,minJ) == J
end

@testset "dimensions of localizations at prime ideals" begin
  R, (x, y, z) = QQ[:x, :y, :z]
  A, pr = quo(R, ideal(R, [x^2 + 1]))
  U = complement_of_prime_ideal(modulus(A) + ideal(R, y))
  L, loc = localization(A, U)
  @test dim(L) == 1

  U = complement_of_prime_ideal(modulus(A))
  L, loc = localization(A, U)
  @test dim(L) == 0

  U = complement_of_prime_ideal(modulus(A) + ideal(R, [y, z]))
  L, loc = localization(A, U)
  @test dim(L) == 2
end
