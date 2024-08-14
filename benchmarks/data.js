window.BENCHMARK_DATA = {
  "lastUpdate": 1723594447845,
  "repoUrl": "https://github.com/EarthSciML/EnvironmentalTransport.jl",
  "entries": {
    "Julia benchmark result": [
      {
        "commit": {
          "author": {
            "email": "ctessum@gmail.com",
            "name": "Christopher Tessum",
            "username": "ctessum"
          },
          "committer": {
            "email": "ctessum@gmail.com",
            "name": "Christopher Tessum",
            "username": "ctessum"
          },
          "distinct": true,
          "id": "ffbb742848d68a3d162d509fb2965796a094db5a",
          "message": "Update benchmarks",
          "timestamp": "2024-08-14T08:58:56+09:00",
          "tree_id": "659b62a46f69dacb141084f9f38e48bcb6374b47",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/ffbb742848d68a3d162d509fb2965796a094db5a"
        },
        "date": 1723594447404,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1492106,
            "unit": "ns",
            "extra": "gctime=0\nmemory=441808\nallocs=2514\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2320396,
            "unit": "ns",
            "extra": "gctime=0\nmemory=620240\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 3076796,
            "unit": "ns",
            "extra": "gctime=0\nmemory=763456\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4665857,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1102848\nallocs=6730\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12458390,
            "unit": "ns",
            "extra": "gctime=0\nmemory=505648\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19237949.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=718224\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24934930,
            "unit": "ns",
            "extra": "gctime=0\nmemory=890368\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38499191,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1297488\nallocs=6729\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 796763,
            "unit": "ns",
            "extra": "gctime=0\nmemory=202000\nallocs=455\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 1177462,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1516336,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 2388608.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=361296\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7619097,
            "unit": "ns",
            "extra": "gctime=0\nmemory=201680\nallocs=451\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11562376,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14938802,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22810741,
            "unit": "ns",
            "extra": "gctime=0\nmemory=360976\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}