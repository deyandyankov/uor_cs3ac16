const cores = Sys.CPU_CORES
process = 2
processes = nprocs()

function create_processes()
  processes = nprocs()
  if processes == 1
    addprocs(cores)
  end
end

function next_process()
  global process
  process = process == processes ? 2 : process + 1
  return process
end
