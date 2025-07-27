using MOMetrics
using Test

@testset "MOMetrics.jl" begin
    @testset "nonDominated" begin
        # Teste com matriz vazia
        @test nonDominated(Matrix{Float64}(undef, 0, 2)) == (0, [])
        
        # Teste com um ponto
        A = [1.0 2.0]
        count, result = nonDominated(A)
        @test count == 1
        @test result == A
        
        # Teste com pontos dominados
        A = [1.0 2.0; 2.0 3.0; 0.5 1.5]  # O terceiro ponto domina o primeiro
        count, result = nonDominated(A)
        @test count == 2
        @test size(result, 1) == 2
    end
    
    @testset "IsNonDominated" begin
        # Teste com conjunto vazio
        @test IsNonDominated([1.0, 2.0], Matrix{Float64}(undef, 0, 2)) == true
        
        # Teste com ponto não dominado
        A = [1.0 2.0; 3.0 1.0]
        @test IsNonDominated([0.5, 1.5], A) == true
        
        # Teste com ponto dominado
        @test IsNonDominated([2.0, 3.0], A) == false
    end
end 