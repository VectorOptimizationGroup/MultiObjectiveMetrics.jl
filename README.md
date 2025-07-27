# MOMetrics.jl

Um pacote Julia para cálculo de métricas em otimização multiobjetivo.

## Instalação

```julia
using Pkg
Pkg.add("https://github.com/seu-usuario/MOMetrics.jl.git")
```

## Uso

```julia
using MOMetrics

# Extrair pontos não dominados
A = [1.0 2.0; 2.0 3.0; 0.5 1.5]
count, nondominated_points = nonDominated(A)

# Verificar se um ponto é não dominado
x = [0.5, 1.5]
is_nondominated = IsNonDominated(x, A)
```

## Funções Disponíveis

- `nonDominated(A)`: Extrai os pontos não dominados de uma matriz de pontos
- `IsNonDominated(x, A)`: Verifica se um ponto x é não dominado em relação ao conjunto A

## Desenvolvimento

Para contribuir com o desenvolvimento:

1. Clone o repositório
2. Entre no diretório do pacote
3. Execute `julia --project=.` para ativar o ambiente
4. Execute `using Pkg; Pkg.instantiate()` para instalar dependências
5. Execute `include("test/runtests.jl")` para rodar os testes 