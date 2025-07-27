"""
    nonDominated(A)

Extrai os pontos não dominados de uma lista de pontos.

# Argumentos
- `A`: Matriz onde cada linha representa um ponto no espaço objetivo

# Retorna
- `nFPA`: Número de pontos não dominados
- `A`: Matriz contendo apenas os pontos não dominados

# Exemplo
```julia
A = [1.0 2.0; 2.0 3.0; 0.5 1.5]
count, nondominated = nonDominated(A)
```
"""
function nonDominated(A)
    # Esta função extrai os pontos não dominados de uma lista de pontos
    #TODO SE LIVRE DISSO MAIS BREVE POSSIVEL, PRECISAMOS TRABALHAR COM A CORRETA
    A = normalize_to_matrix(A)
    
    # Verificar se A é vazio
    if isempty(A)
        return 0, []
    end

    # Remover pontos equivalentes
    tol = 1e-5
    
    remove = Int[]
    
    # Usar axes para obter os índices das linhas
    rows = axes(A, 1)
    
    for i in rows
        if i in remove
            continue
        end
        
        x = A[i, :]
        
        # Usar apenas índices maiores que i
        for j in (i+1):last(rows)
            if j in remove
                continue
            end
            
            y = A[j, :]
            
            # Aplicar abs elemento a elemento
            maxxy = maximum(abs.(x .- y) ./ max.(1, abs.(x)))
            
            if maxxy <= tol
                push!(remove, j)
            end
        end
    end
    
    # Remover os pontos equivalentes
    if !isempty(remove)
        A = A[setdiff(rows, remove), :]
    end
    
    # Atualizar os índices das linhas após a remoção
    rows = axes(A, 1)
    
    # Remover os pontos dominados
    remove = Int[]
    
    for i in rows
        if i in remove
            continue
        end
        
        x = A[i, :]
        
        for j in rows
            if j == i || j in remove
                continue
            end
            
            y = A[j, :]
            
            # Verificar se y domina x
            # (min(y - x <= tol * max(1, abs(x))) == 1) && (max(y - x < -tol * max(1, abs(x))) == 1)
            if all(y .- x .<= tol .* max.(1, abs.(x))) && any(y .- x .< -tol .* max.(1, abs.(x)))
                push!(remove, i)
                break  # Se x é dominado, podemos parar de verificar outros pontos
            end
        end
    end
    
    # Remover os pontos dominados
    if !isempty(remove)
        A = A[setdiff(rows, remove), :]
    end
    
    nFPA = size(A, 1)
    
    return nFPA, A
end

"""
    IsNonDominated(x, A)

Verifica se o ponto x é não dominado em relação ao conjunto de pontos A.

# Argumentos
- `x`: Vetor representando um ponto no espaço objetivo
- `A`: Matriz onde cada linha representa um ponto no espaço objetivo

# Retorna
- `IsND`: `true` se x é não dominado, `false` caso contrário

# Exemplo
```julia
A = [1.0 2.0; 3.0 1.0]
x = [0.5, 1.5]
is_nondominated = IsNonDominated(x, A)
```
"""
function IsNonDominated(x, A)
    # Esta função verifica se x é um ponto não dominado em relação a uma lista
    # de pontos não dominados fornecidos em A

    A = normalize_to_matrix(A)
    
    tol = 1e-5
    
    # Verificar se A é vazio
    if isempty(A)
        return true
    end
    
    nPoints = size(A, 1)
    
    IsND = true
    
    for i in 1:nPoints
        y = A[i, :]
        
        # Verificar se x é equivalente a y
        maxxy = maximum(abs.(x .- y) ./ max.(1, abs.(x)))
        
        if maxxy <= 10 * tol
            IsND = true
            return IsND
        end
        
        # Verificar se x é dominado por y
        if all(y .- x .<= tol .* max.(1, abs.(x))) && any(y .- x .< -tol .* max.(1, abs.(x)))
            IsND = false
            return IsND
        end
    end
    
    return IsND
end

# Função auxiliar para normalizar diferentes tipos de entrada para uma matriz 2D
function normalize_to_matrix(A)
    try
        # Caso 1: A já é uma matriz 2D
        if isa(A, Matrix)
            return A
        end
        
        # Caso 2: A é um vetor de vetores
        if isa(A, Vector) && all(isa(item, Vector) for item in A if !isempty(A))
            # Verificar se todos os vetores têm o mesmo tamanho
            if !isempty(A)
                first_length = length(A[1])
                A_filtered = filter(x -> length(x) == first_length, A)
                
                if !isempty(A_filtered)
                    # Converter para matriz
                    return reduce(vcat, [reshape(v, 1, :) for v in A_filtered])
                end
            end
        end
        
        # Caso 3: A é um vetor de matrizes
        if isa(A, Vector) && all(isa(item, Matrix) for item in A if !isempty(A))
            # Verificar se todas as matrizes têm o mesmo número de colunas
            if !isempty(A)
                filtered_matrices = filter(m -> !isempty(m), A)
                
                if !isempty(filtered_matrices)
                    first_cols = size(filtered_matrices[1], 2)
                    if all(size(m, 2) == first_cols for m in filtered_matrices)
                        # Concatenar verticalmente
                        return vcat(filtered_matrices...)
                    end
                end
            end
        end
        
        # Caso 4: A é um tipo Any[] que contém vetores, matrizes ou outros Any[]
        if isa(A, Vector)
            # Extrair todos os elementos que são vetores ou matrizes
            A_converted = []
            
            for item in A
                if isa(item, AbstractVector)
                    if isa(item, Vector{Any}) || eltype(item) == Any
                        # Se for um Any[], processar recursivamente
                        nested_matrix = normalize_to_matrix(item)
                        if !isempty(nested_matrix)
                            # Se for uma matriz, adicionar cada linha como um vetor
                            for i in axes(nested_matrix, 1)
                                push!(A_converted, nested_matrix[i, :])
                            end
                        end
                    else
                        # Se for um vetor comum, adicionar diretamente
                        push!(A_converted, item)
                    end
                elseif isa(item, Matrix)
                    # Se for uma matriz, adicionar cada linha como um vetor
                    for i in axes(item, 1)
                        push!(A_converted, item[i, :])
                    end
                elseif isa(item, Number)
                    # Se for um número, converter para um vetor de um elemento
                    push!(A_converted, [item])
                else
                    # Tentar converter para vetor
                    try
                        v = convert(Vector{Float64}, item)
                        push!(A_converted, v)
                    catch
                        # Ignorar se não puder converter
                    end
                end
            end
            
            # Se conseguimos extrair algum elemento
            if !isempty(A_converted)
                # Verificar se todos os vetores têm o mesmo tamanho
                first_length = length(A_converted[1])
                A_filtered = filter(x -> length(x) == first_length, A_converted)
                
                if !isempty(A_filtered)
                    # Converter para matriz
                    return reduce(vcat, [reshape(v, 1, :) for v in A_filtered])
                end
            end
        end
        
        # Se chegou aqui, não conseguiu converter
        @warn "Não foi possível converter a entrada para uma matriz: $(typeof(A))"
        return Matrix{Float64}(undef, 0, 0)
    catch e
        @warn "Erro ao normalizar a entrada: $e"
        return Matrix{Float64}(undef, 0, 0)
    end
end