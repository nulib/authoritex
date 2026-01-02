ExUnit.start()
Req.default_options(retry: false)
{:ok, _pid} =
  Finch.start_link(
    name: TestPool,
    pools: %{
      default: [size: 100]
    }
  )
