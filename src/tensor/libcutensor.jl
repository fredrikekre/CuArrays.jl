# Julia wrapper for header: types.h
# Automatically generated using Clang.jl

# Julia wrapper for header: cutensor.h
# Automatically generated using Clang.jl


function cutensorCreate(handle)
    @check @runtime_ccall((:cutensorInit, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},),
                 handle)
end

function cutensorCreateTensorDescriptor(handle, desc, numModes, extent, stride, dataType, unaryOp)
    @check @runtime_ccall((:cutensorInitTensorDescriptor, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t}, Ptr{cutensorTensorDescriptor_t}, UInt32, Ptr{Int64}, Ptr{Int64},
                  cudaDataType_t, cutensorOperator_t),
                 handle, desc, numModes, extent, stride, dataType, unaryOp)
end


function cutensorElementwiseTrinary(handle,
                                    alpha, A, descA, modeA,
                                    beta,  B, descB, modeB,
                                    gamma, C, descC, modeC,
                                           D, descD, modeD,
                                    opAB, opABC, typeCompute, stream)
    @check @runtime_ccall((:cutensorElementwiseTrinary, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                              CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  cutensorOperator_t, cutensorOperator_t, cudaDataType_t, CUstream),
                 handle, alpha, A, descA, modeA, beta, B, descB, modeB, gamma, C, descC,
                 modeC, D, descD, modeD, opAB, opABC, typeCompute, stream)
end

function cutensorElementwiseBinary(handle,
                                   alpha, A, descA, modeA,
                                   gamma, C, descC, modeC,
                                          D, descD, modeD,
                                   opAC, typeCompute, stream)
    @check @runtime_ccall((:cutensorElementwiseBinary, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                              CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  cutensorOperator_t, cudaDataType_t, CUstream),
                 handle, alpha, A, descA, modeA, gamma, C, descC, modeC, D, descD, modeD,
                 opAC, typeCompute, stream)
end

function cutensorPermutation(handle,
                             alpha, A, descA, modeA,
                                    B, descB, modeB,
                             typeCompute, stream)
    @check @runtime_ccall((:cutensorPermutation, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},
                  Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                              CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  cudaDataType_t, CUstream),
                 handle, alpha, A, descA, modeA, B, descB, modeB, typeCompute, stream)
end

function cutensorInitContractionDescriptor(handle,
                   desc,
                   descA, modeA, alignmentRequirementA,
                   descB, modeB, alignmentRequirementB,
                   descC, modeC, alignmentRequirementC,
                   descD, modeD, alignmentRequirementD,
                   computeType)
    @check @runtime_ccall((:cutensorInitContractionDescriptor, libcutensor), cutensorStatus_t,
                  (Ptr{cutensorHandle_t}, Ptr{cutensorContractionDescriptor_t},
                  Ptr{cutensorTensorDescriptor_t}, Ptr{Int32}, UInt32,
                  Ptr{cutensorTensorDescriptor_t}, Ptr{Int32}, UInt32,
                  Ptr{cutensorTensorDescriptor_t}, Ptr{Int32}, UInt32,
                  Ptr{cutensorTensorDescriptor_t}, Ptr{Int32}, UInt32,
                  cutensorComputeType_t), handle,
                   desc,
                   descA, modeA, alignmentRequirementA,
                   descB, modeB, alignmentRequirementB,
                   descC, modeC, alignmentRequirementC,
                   descD, modeD, alignmentRequirementD,
                   computeType)

end

function cutensorInitContractionFind(handle, find, algo)
    @check @runtime_ccall((:cutensorInitContractionFind, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},
                  Ptr{cutensorContractionFind_t},
                  cutensorAlgo_t), handle, find, algo)
end

function cutensorContractionGetWorkspace(handle, desc, find, pref, workspaceSize)
    @check @runtime_ccall((:cutensorContractionGetWorkspace, libcutensor), cutensorStatus_t,
                          (Ptr{cutensorHandle_t},
                           Ptr{cutensorContractionDescriptor_t},
                           Ptr{cutensorContractionFind_t}, cutensorWorksizePreference_t, Ptr{UInt64}),
                 handle, desc, find, pref, workspaceSize)
end

function cutensorInitContractionPlan(handle, plan, desc, find, workspaceSize)
    @check @runtime_ccall((:cutensorInitContractionPlan, libcutensor), cutensorStatus_t,
                          (Ptr{cutensorHandle_t},
                           Ptr{cutensorContractionPlan_t},
                           Ptr{cutensorContractionDescriptor_t},
                           Ptr{cutensorContractionFind_t},
                           UInt64), handle, plan, desc, find, workspaceSize)
end

function cutensorContraction(handle, plan,
                             alpha, A, B,
                             beta,  C, D,
                             workspace, workspaceSize, stream)
    @check @runtime_ccall((:cutensorContraction, libcutensor), cutensorStatus_t,
                          (Ptr{cutensorHandle_t},
                           Ptr{cutensorContractionPlan_t},
                           Ptr{Cvoid}, CuPtr{Cvoid}, CuPtr{Cvoid},
                           Ptr{Cvoid}, CuPtr{Cvoid}, CuPtr{Cvoid},
                           CuPtr{Cvoid}, UInt64, CUstream),
                             handle, plan,
                             alpha, A, B,
                             beta,  C, D,
                             workspace, workspaceSize, stream)

end

function cutensorContractionMaxAlgos(maxNumAlgos)
    @check @runtime_ccall((:cutensorContractionMaxAlgos, libcutensor), cutensorStatus_t,
                 (Ptr{Int32},),
                 maxNumAlgos)
end

function cutensorReduction(handle,
                           alpha, A, descA, modeA,
                           beta,  C, descC, modeC,
                                  D, descD, modeD,
                           opReduce, typeCompute, workspace, workspaceSize, stream)
    @check @runtime_ccall((:cutensorReduction, libcutensor), cutensorStatus_t,
                  (Ptr{cutensorHandle_t},
                   Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                   Ptr{Cvoid}, CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                               CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  cutensorOperator_t, cudaDataType_t, CuPtr{Cvoid}, UInt64, CUstream),
                 handle, alpha, A, descA, modeA, beta, C, descC, modeC, D, descD, modeD,
                 opReduce, typeCompute, workspace, workspaceSize, stream)
end

function cutensorReductionGetWorkspace(handle, A, descA_, modeA, C, descC_, modeC, D,
                                       descD_, modeD, opReduce, typeCompute, workspaceSize)
    @check @runtime_ccall((:cutensorReductionGetWorkspace, libcutensor), cutensorStatus_t,
                  (Ptr{cutensorHandle_t},
                  CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{Int32},
                  cutensorOperator_t, cudaDataType_t, Ptr{UInt64}),
                 handle, A, descA_, modeA,
                         C, descC_, modeC,
                         D, descD_, modeD, opReduce, typeCompute, workspaceSize)
end

function cutensorGetAlignmentRequirement(handle, ptr, desc, alignmentRequirement)
    @check @runtime_ccall((:cutensorGetAlignmentRequirement, libcutensor), cutensorStatus_t,
                 (Ptr{cutensorHandle_t},
                  CuPtr{Cvoid}, Ptr{cutensorTensorDescriptor_t}, Ptr{UInt32}), handle, ptr,desc, alignmentRequirement)
end

function cutensorGetErrorString(error)
    @runtime_ccall((:cutensorGetErrorString, libcutensor), Cstring,
          (cutensorStatus_t,),
          error)
end

function cutensorGetVersion()
    @runtime_ccall((:cutensorGetVersion, libcutensor), Csize_t, ())
end

function cutensorGetCudartVersion()
    @runtime_ccall((:cutensorGetCudartVersion, libcutensor), Csize_t, ())
end
