# wrappers of low-level functionality

using CUDAapi: cudaDataType
using CUDAdrv: CuDefaultStream, CuStream

function version()
    ver = cutensorGetVersion()
    major, ver = divrem(ver, 10000)
    minor, patch = divrem(ver, 100)

    VersionNumber(major, minor, patch)
end

function cutensorCreate()
    handle = Ref{cutensorHandle_t}()
    cutensorCreate(handle)
    handle[]
end

const ModeType = AbstractVector{<:Union{Char, Integer}}

is_unary(op::cutensorOperator_t) =
    (op ∈ (CUTENSOR_OP_IDENTITY, CUTENSOR_OP_SQRT, CUTENSOR_OP_RELU, CUTENSOR_OP_CONJ,
            CUTENSOR_OP_RCP))
is_binary(op::cutensorOperator_t) =
    (op ∈ (CUTENSOR_OP_ADD, CUTENSOR_OP_MUL, CUTENSOR_OP_MAX, CUTENSOR_OP_MIN))

mutable struct CuTensorDescriptor
    desc::Ref{cutensorTensorDescriptor_t}

    function CuTensorDescriptor(a; size = size(a), strides = strides(a), eltype = eltype(a),
                                   op = CUTENSOR_OP_IDENTITY)
        sz = collect(Int64, size)
        st = collect(Int64, strides)
        desc = Ref{cutensorTensorDescriptor_t}()
        cutensorInitTensorDescriptor(handle(), desc, length(sz), sz, st,
                                     cudaDataType(eltype), op)
        obj = new(desc)
        return obj
    end
end

Base.cconvert(::Type{Ptr{cutensorTensorDescriptor_t}}, obj::CuTensorDescriptor) = obj.desc

function elementwiseTrinary!(
    alpha::Number, A::CuArray, Ainds::ModeType, opA::cutensorOperator_t,
    beta::Number,  B::CuArray, Binds::ModeType, opB::cutensorOperator_t,
    gamma::Number, C::CuArray{T}, Cinds::ModeType, opC::cutensorOperator_t,
    D::CuArray{T}, Dinds::ModeType, opAB::cutensorOperator_t,
    opABC::cutensorOperator_t; stream::CuStream=CuDefaultStream()) where {T}

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opB)    && throw(ArgumentError("opB must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opAB)  && throw(ArgumentError("opAB must be a binary op!"))
    !is_binary(opABC) && throw(ArgumentError("opABC must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descB = CuTensorDescriptor(B; op = opB)
    descC = CuTensorDescriptor(C; op = opC)
    @assert size(C) == size(D) && strides(C) == strides(D)
    descD = descC # must currently be identical
    #typeCompute = cudaDataType(T)
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeB = collect(Cint, Binds)
    modeC = collect(Cint, Cinds)
    modeD = modeC
    cutensorElementwiseTrinary(handle(),
                                T[alpha], A, descA, modeA,
                                T[beta],  B, descB, modeB,
                                T[gamma], C, descC, modeC,
                                          D, descD, modeD,
                                opAB, opABC, typeCompute, stream)
    return D
end

function elementwiseTrinary!(
    alpha::Number, A::Array, Ainds::ModeType, opA::cutensorOperator_t,
    beta::Number, B::Array, Binds::ModeType, opB::cutensorOperator_t,
    gamma::Number, C::Array{T}, Cinds::ModeType, opC::cutensorOperator_t,
    D::Array{T}, Dinds::ModeType, opAB::cutensorOperator_t,
    opABC::cutensorOperator_t; stream::CuStream=CuDefaultStream()) where {T}

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opB)    && throw(ArgumentError("opB must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opAB)  && throw(ArgumentError("opAB must be a binary op!"))
    !is_binary(opABC) && throw(ArgumentError("opABC must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descB = CuTensorDescriptor(B; op = opB)
    descC = CuTensorDescriptor(C; op = opC)
    @assert size(C) == size(D) && strides(C) == strides(D)
    descD = descC # must currently be identical
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeB = collect(Cint, Binds)
    modeC = collect(Cint, Cinds)
    modeD = modeC
    cutensorElementwiseTrinary(handle(),
                               T[alpha], A, descA, modeA,
                               T[beta],  B, descB, modeB,
                               T[gamma], C, descC, modeC,
                                         D, descD, modeD,
                               opAB, opABC, typeCompute, stream)
    return D
end

function elementwiseBinary!(
    alpha::Number, A::CuArray, Ainds::ModeType, opA::cutensorOperator_t,
    gamma::Number, C::CuArray{T}, Cinds::ModeType, opC::cutensorOperator_t,
    D::CuArray{T}, Dinds::ModeType, opAC::cutensorOperator_t;
    stream::CuStream=CuDefaultStream()) where {T}

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opAC)  && throw(ArgumentError("opAC must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descC = CuTensorDescriptor(C; op = opC)
    @assert size(C) == size(D) && strides(C) == strides(D)
    descD = descC # must currently be identical
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeC = collect(Cint, Cinds)
    modeD = modeC
    cutensorElementwiseBinary(handle(),
                              T[alpha], A, descA, modeA,
                              T[gamma], C, descC, modeC,
                                        D, descD, modeD,
                              opAC, typeCompute, stream)
    return D
end

function elementwiseBinary!(
    alpha::Number, A::Array, Ainds::ModeType, opA::cutensorOperator_t,
    gamma::Number, C::Array{T}, Cinds::ModeType, opC::cutensorOperator_t,
    D::Array{T}, Dinds::ModeType, opAC::cutensorOperator_t;
    stream::CuStream=CuDefaultStream()) where {T}

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opAC)  && throw(ArgumentError("opAC must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descC = CuTensorDescriptor(C; op = opC)
    @assert size(C) == size(D) && strides(C) == strides(D)
    descD = descC # must currently be identical
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeC = collect(Cint, Cinds)
    modeD = modeC
    cutensorElementwiseBinary(handle(),
                              T[alpha], A, descA, modeA,
                              T[gamma], C, descC, modeC,
                                        D, descD, modeD,
                              opAC, typeCompute, stream)
    return D
end

function elementwiseBinary!(
    alpha::Number, A::CuTensor, opA::cutensorOperator_t, gamma::Number, C::CuTensor{T}, opC::cutensorOperator_t, D::CuTensor{T}, opAC::cutensorOperator_t; stream::CuStream=CuDefaultStream()) where {T}

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opAC)  && throw(ArgumentError("opAC must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descC = CuTensorDescriptor(C; op = opC)
    @assert size(C) == size(D) && strides(C) == strides(D)
    descD = descC # must currently be identical
    typeCompute = cudaDataType(T)
    cutensorElementwiseBinary(handle(),
                              T[alpha], A.data, descA, A.inds,
                              T[gamma], C.data, descC, C.inds,
                                        D.data, descD, C.inds,
                              opAC, typeCompute, stream)
    return D
end

function permutation!(alpha::Number, A::CuArray, Ainds::ModeType,
                      B::CuArray, Binds::ModeType; stream::CuStream=CuDefaultStream())
    #!is_unary(opPsi)    && throw(ArgumentError("opPsi must be a unary op!"))
    descA = CuTensorDescriptor(A)
    descB = CuTensorDescriptor(B)
    T = eltype(B)
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeB = collect(Cint, Binds)
    cutensorPermutation(handle(), T[alpha], A, descA, modeA, B, descB, modeB, typeCompute,
                        stream)
    return B
end
function permutation!(alpha::Number, A::Array, Ainds::ModeType,
                      B::Array, Binds::ModeType; stream::CuStream=CuDefaultStream())
    #!is_unary(opPsi)    && throw(ArgumentError("opPsi must be a unary op!"))
    descA = CuTensorDescriptor(A)
    descB = CuTensorDescriptor(B)
    T = eltype(B)
    typeCompute = cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeB = collect(Cint, Binds)
    cutensorPermutation(handle(), T[alpha], A, descA, modeA, B, descB, modeB, typeCompute,
                        stream)
    return B
end

function contraction!(
    alpha::Number, A::CuArray, Ainds::ModeType, opA::cutensorOperator_t,
                   B::CuArray, Binds::ModeType, opB::cutensorOperator_t,
    beta::Number,  C::CuArray, Cinds::ModeType, opC::cutensorOperator_t,
                                                opOut::cutensorOperator_t,
    pref::cutensorWorksizePreference_t=CUTENSOR_WORKSPACE_RECOMMENDED,
    algo::cutensorAlgo_t=CUTENSOR_ALGO_DEFAULT, stream::CuStream=CuDefaultStream())

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opB)    && throw(ArgumentError("opB must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_unary(opOut)  && throw(ArgumentError("opOut must be a unary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descB = CuTensorDescriptor(B; op = opB)
    descC = CuTensorDescriptor(C; op = opC)
    # for now, D must be identical to C (and thus, descD must be identical to descC)
    T = eltype(C)
    computeType = cutensorComputeType(T) #CUTENSOR_R_MIN_64F #TODO cudaDataType(T)
    modeA = collect(Cint, Ainds)
    modeB = collect(Cint, Binds)
    modeC = collect(Cint, Cinds)

    alignmentRequirementA = Ref{UInt32}(C_NULL) #TODO init?
    cutensorGetAlignmentRequirement(handle(), A, descA, alignmentRequirementA)
    alignmentRequirementB = Ref{UInt32}(C_NULL) #TODO init?
    cutensorGetAlignmentRequirement(handle(), B, descB, alignmentRequirementB)
    alignmentRequirementC = Ref{UInt32}(C_NULL) #TODO init?
    cutensorGetAlignmentRequirement(handle(), C, descC, alignmentRequirementC)

    #desc = Ref{cutensorContractionDescriptor_t}(C_NULL) #TODO init?
    desc = Ref{cutensorContractionDescriptor_t}(cutensorContractionDescriptor_t(ntuple(i->0,512))) #TODO init?
    cutensorInitContractionDescriptor(handle(),
                                      desc,
                   descA, modeA, alignmentRequirementA[],
                   descB, modeB, alignmentRequirementB[],
                   descC, modeC, alignmentRequirementC[],
                   descC, modeC, alignmentRequirementC[],
                   computeType)

    find = Ref{cutensorContractionFind_t}(cutensorContractionFind_t(ntuple(i->0,512))) #TODO init?
    cutensorInitContractionFind(handle(), find, algo)

    workspaceSize = Ref{UInt64}(C_NULL)
    cutensorContractionGetWorkspace(handle(), desc, find, pref, workspaceSize)

    plan = Ref(cutensorContractionPlan_t(ntuple(i->0, 512))) #TODO init?
    cutensorInitContractionPlan(handle(), desc, find, workspaceSize[], plan)

    workspace = CuArray{UInt8}(undef, 0)
    try
        workspace = CuArray{UInt8}(undef, workspaceSize[])
    catch
        workspace = CuArray{UInt8}(undef, 1<<27)
    end
    workspaceSize[] = length(workspace)

    cutensorContraction(handle(), plan,
                        T[alpha], A, B,
                        T[beta],  C, C,
                        workspace, workspaceSize[], stream)
    return C
end

#function contraction!(
#    alpha::Number, A::Array, Ainds::ModeType, opA::cutensorOperator_t,
#                   B::Array, Binds::ModeType, opB::cutensorOperator_t,
#    beta::Number,  C::Array, Cinds::ModeType, opC::cutensorOperator_t,
#    pref::cutensorWorksizePreference_t=CUTENSOR_WORKSPACE_RECOMMENDED,
#    algo::cutensorAlgo_t=CUTENSOR_ALGO_DEFAULT, stream::CuStream=CuDefaultStream())
#
#    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
#    !is_unary(opB)    && throw(ArgumentError("opB must be a unary op!"))
#    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
#    descA = CuTensorDescriptor(A; op = opA)
#    descB = CuTensorDescriptor(B; op = opB)
#    descC = CuTensorDescriptor(C; op = opC)
#    # for now, D must be identical to C (and thus, descD must be identical to descC)
#    T = eltype(C)
#    typeCompute = cudaDataType(T)
#    modeA = collect(Cint, Ainds)
#    modeB = collect(Cint, Binds)
#    modeC = collect(Cint, Cinds)
#
#    workspaceSize = Ref{UInt64}(C_NULL)
#    cutensorContractionGetWorkspace(handle(), A, descA, modeA, B, descB, modeB, C, descC,
#                                    modeC, C, descC, modeC, typeCompute, algo, pref,
#                                    workspaceSize)
#    workspace = CuArray{UInt8}(undef, 0)
#    try
#        workspace = CuArray{UInt8}(undef, workspaceSize[])
#    catch
#        workspace = CuArray{UInt8}(undef, 1<<27)
#    end
#    workspaceSize[] = length(workspace)
#
#    cutensorContraction(handle(), T[alpha], A, descA, modeA, B, descB, modeB, T[beta], C,
#                        descC, modeC, C, descC, modeC, typeCompute, algo, CU_NULL, 0,
#                        stream)
#    return C
#end
#
#function contraction!(
#    alpha::Number, A::CuTensor, opA::cutensorOperator_t,
#                   B::CuTensor, opB::cutensorOperator_t,
#    beta::Number,  C::CuTensor, opC::cutensorOperator_t,
#    pref::cutensorWorksizePreference_t=CUTENSOR_WORKSPACE_RECOMMENDED,
#    algo::cutensorAlgo_t=CUTENSOR_ALGO_DEFAULT, stream::CuStream=CuDefaultStream())
#
#    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
#    !is_unary(opB)    && throw(ArgumentError("opB must be a unary op!"))
#    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
#    descA = CuTensorDescriptor(A; op = opA)
#    descB = CuTensorDescriptor(B; op = opB)
#    descC = CuTensorDescriptor(C; op = opC)
#    # for now, D must be identical to C (and thus, descD must be identical to descC)
#    T = eltype(C)
#    typeCompute = cudaDataType(T)
#
#    workspaceSize = Ref{UInt64}(C_NULL)
#    cutensorContractionGetWorkspace(handle(), A.data, descA, A.inds, B.data, descB, B.inds,
#                                    C.data, descC, C.inds, C.data, descC, C.inds,
#                                    typeCompute, algo, pref, workspaceSize)
#    workspace = CuArray{UInt8}(undef, 0)
#    try
#        workspace = CuArray{UInt8}(undef, workspaceSize[])
#    catch
#        workspace = CuArray{UInt8}(undef, 1<<27)
#    end
#    workspaceSize[] = length(workspace)
#
#    cutensorContraction(handle(), T[alpha], A.data, descA, A.inds, B.data, descB, B.inds,
#                        T[beta], C.data, descC, C.inds, C.data, descC, C.inds,
#                        typeCompute, algo, workspace, workspaceSize[], stream)
#    return C
#end

function reduction!(
    alpha::Number, A::CuArray, Ainds::ModeType, opA::cutensorOperator_t,
    beta::Number,  C::CuArray, Cinds::ModeType, opC::cutensorOperator_t,
    opReduce::cutensorOperator_t; stream::CuStream=CuDefaultStream())

    !is_unary(opA)    && throw(ArgumentError("opA must be a unary op!"))
    !is_unary(opC)    && throw(ArgumentError("opC must be a unary op!"))
    !is_binary(opReduce)  && throw(ArgumentError("opReduce must be a binary op!"))
    descA = CuTensorDescriptor(A; op = opA)
    descC = CuTensorDescriptor(C; op = opC)
    # for now, D must be identical to C (and thus, descD must be identical to descC)
    T = eltype(C)
    typeCompute = cutensorComputeType(T)
    modeA = collect(Cint, Ainds)
    modeC = collect(Cint, Cinds)

    workspaceSize = Ref{UInt64}(C_NULL)
    cutensorReductionGetWorkspace(handle(),
                                  A, descA, modeA,
                                  C, descC, modeC,
                                  C, descC, modeC,
                                  opReduce, typeCompute, workspaceSize)
    workspace = CuArray{UInt8}(undef, 0)
    try
        workspace = CuArray{UInt8}(undef, workspaceSize[])
    catch
        workspace = CuArray{UInt8}(undef, 1<<13)
    end
    workspaceSize[] = length(workspace)

    cutensorReduction(handle(),
                      T[alpha], A, descA, modeA,
                      T[beta],  C, descC, modeC,
                                C, descC, modeC,
                       opReduce, typeCompute, workspace, workspaceSize[], stream)
    return C
end
