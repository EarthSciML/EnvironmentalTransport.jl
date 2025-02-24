window.BENCHMARK_DATA = {
  "lastUpdate": 1740415268345,
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
      },
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
          "id": "c1a950b0311f2d32a3b36ed885ee61b448bc6709",
          "message": "Add benchmarks to docs",
          "timestamp": "2024-08-14T11:44:12+09:00",
          "tree_id": "4d78d70e08d306410da585ff7950d72f832ad258",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/c1a950b0311f2d32a3b36ed885ee61b448bc6709"
        },
        "date": 1723604374494,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1561785,
            "unit": "ns",
            "extra": "gctime=0\nmemory=441776\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2365069,
            "unit": "ns",
            "extra": "gctime=0\nmemory=620240\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 3110475,
            "unit": "ns",
            "extra": "gctime=0\nmemory=763456\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4716241,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1102848\nallocs=6730\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12437249,
            "unit": "ns",
            "extra": "gctime=0\nmemory=505680\nallocs=2514\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19187235,
            "unit": "ns",
            "extra": "gctime=0\nmemory=718224\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24883293,
            "unit": "ns",
            "extra": "gctime=0\nmemory=890400\nallocs=4550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38328840,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1297488\nallocs=6729\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 789098,
            "unit": "ns",
            "extra": "gctime=0\nmemory=201680\nallocs=451\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 1159568,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1507803,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 2323721,
            "unit": "ns",
            "extra": "gctime=0\nmemory=361296\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7603887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=202000\nallocs=455\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11535758,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14893142.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283536\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22757847,
            "unit": "ns",
            "extra": "gctime=0\nmemory=360976\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "93cb7384d1d6200421e6bdf95e2b93e5dff5583c",
          "message": "Fix benchmarks link?",
          "timestamp": "2024-08-15T10:02:33+09:00",
          "tree_id": "1df4e8b4ea6defeaa8e1caee419f259d0a902b76",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/93cb7384d1d6200421e6bdf95e2b93e5dff5583c"
        },
        "date": 1723684668413,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1487709,
            "unit": "ns",
            "extra": "gctime=0\nmemory=441808\nallocs=2514\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2313241,
            "unit": "ns",
            "extra": "gctime=0\nmemory=620240\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 3066272.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=763456\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4661734,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1102816\nallocs=6728\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12410905,
            "unit": "ns",
            "extra": "gctime=0\nmemory=505680\nallocs=2514\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19140070,
            "unit": "ns",
            "extra": "gctime=0\nmemory=718224\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24889727,
            "unit": "ns",
            "extra": "gctime=0\nmemory=890368\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38366104,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1297488\nallocs=6729\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 799288,
            "unit": "ns",
            "extra": "gctime=0\nmemory=202000\nallocs=455\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 1176545,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1529276,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 2319357,
            "unit": "ns",
            "extra": "gctime=0\nmemory=360976\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7562257,
            "unit": "ns",
            "extra": "gctime=0\nmemory=202000\nallocs=455\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11529682,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14886876.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22739186,
            "unit": "ns",
            "extra": "gctime=0\nmemory=360976\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "a8aa4b38aa05158f7002963261d15f6288d8df72",
          "message": "Fix benchmark typos",
          "timestamp": "2024-08-17T20:40:29+09:00",
          "tree_id": "dbf9a72be131c9755720693566772cded61c96e8",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/a8aa4b38aa05158f7002963261d15f6288d8df72"
        },
        "date": 1723895711117,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1472898,
            "unit": "ns",
            "extra": "gctime=0\nmemory=441776\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2247720,
            "unit": "ns",
            "extra": "gctime=0\nmemory=620240\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 3038447.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=763456\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4423359,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1102816\nallocs=6728\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12363846.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=505648\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19503339,
            "unit": "ns",
            "extra": "gctime=0\nmemory=718224\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24587384,
            "unit": "ns",
            "extra": "gctime=0\nmemory=890368\nallocs=4548\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38210515,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1297520\nallocs=6731\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 790534,
            "unit": "ns",
            "extra": "gctime=0\nmemory=201680\nallocs=451\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 1166845,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1500817.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 2319047,
            "unit": "ns",
            "extra": "gctime=0\nmemory=360976\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7546121,
            "unit": "ns",
            "extra": "gctime=0\nmemory=201680\nallocs=451\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11530020,
            "unit": "ns",
            "extra": "gctime=0\nmemory=250896\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14886435.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=283216\nallocs=452\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22550248,
            "unit": "ns",
            "extra": "gctime=0\nmemory=361296\nallocs=456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "38dcb318b3de5f316a3b5ef6deb08441ba8118b6",
          "message": "Update dependencies and make performance improvements",
          "timestamp": "2024-08-23T16:39:41-05:00",
          "tree_id": "03670c73875417ab7e9447c42c1a438ce0a9b1d9",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/38dcb318b3de5f316a3b5ef6deb08441ba8118b6"
        },
        "date": 1724450077628,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1398238,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580528\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2102752,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2736193,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086400\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4134233,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613424\nallocs=15242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12434449.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657552\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19126563,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24775357,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238032\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38165701,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843440\nallocs=15241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 597835,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 859681,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1110746,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1628487,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7460080,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11333385,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14599244,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22351167,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "0d3edc9e9932cf4f93765002cc78865abcfdcf3c",
          "message": "Update demo",
          "timestamp": "2024-08-23T20:58:00-05:00",
          "tree_id": "963d339b977037b729616d3579d0fde62ef394ef",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/0d3edc9e9932cf4f93765002cc78865abcfdcf3c"
        },
        "date": 1724465576788,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1411460,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580528\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2109429,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2742090,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086368\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4140665,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613392\nallocs=15240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12436637,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657552\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19135521,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24797452,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238000\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38149827,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843472\nallocs=15243\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 600399,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 858119,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1112494,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1626673,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7464542,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11334555,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14626451,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22329316,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "c29172da4a831f2f2242798b8246df76c786963c",
          "message": "add first and second-order upwind stencils",
          "timestamp": "2024-08-24T12:59:49-05:00",
          "tree_id": "6899780585b8cf492fa73c20620932701e48a623",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/c29172da4a831f2f2242798b8246df76c786963c"
        },
        "date": 1724523346873,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1396478,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580528\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2100208,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2725524.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086368\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4110938,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613424\nallocs=15242\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12388353.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657584\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19077291,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24700815.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238032\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38097055.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843440\nallocs=15241\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 601446,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 865483,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1116750,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1637265,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7470226.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11333204,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14598400,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22304065,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "e9d0b447fae87d4c6fadb95d735db4ca7603711d",
          "message": "Force positivity in demo",
          "timestamp": "2024-08-24T21:24:15-05:00",
          "tree_id": "9d402b2668ccf41dcc99f2c2aa9b56a8ff29c04e",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/e9d0b447fae87d4c6fadb95d735db4ca7603711d"
        },
        "date": 1724553603775,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1409426,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580560\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2113774,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2743313,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086400\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4131391,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613392\nallocs=15240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12371275,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657584\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19039656.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24679161,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238032\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38026258.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843472\nallocs=15243\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 602058,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 863026.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1115180,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1627701,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7484160,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11348742,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14630094,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22326577,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "83e01035101ac2e1148753887982d738c21c8ef5",
          "message": "Formatting",
          "timestamp": "2024-08-27T20:09:00-05:00",
          "tree_id": "3f4a5810f6f3d02ed39c3e63052eb9abab669688",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/83e01035101ac2e1148753887982d738c21c8ef5"
        },
        "date": 1724808282143,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 796449,
            "unit": "ns",
            "extra": "gctime=0\nmemory=299120\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 1196760.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=420464\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 1547685,
            "unit": "ns",
            "extra": "gctime=0\nmemory=540112\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 2343011.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768576\nallocs=5899\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 8152984,
            "unit": "ns",
            "extra": "gctime=0\nmemory=342896\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 12562452,
            "unit": "ns",
            "extra": "gctime=0\nmemory=485936\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 16253740,
            "unit": "ns",
            "extra": "gctime=0\nmemory=625248\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 25051735.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=895840\nallocs=5900\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 338671,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 476719,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 617806.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 890810,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 4985120,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 7575588,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 9765163.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 14843012,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "fc2d737dc33935f4b331d512c81aa397a499ef38",
          "message": "Add advection stencil tests",
          "timestamp": "2024-08-28T19:14:49-05:00",
          "tree_id": "b99bd2e61b7ab1e1b4f4219e1713761af6b7e2de",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/fc2d737dc33935f4b331d512c81aa397a499ef38"
        },
        "date": 1724891417420,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 762882,
            "unit": "ns",
            "extra": "gctime=0\nmemory=299120\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 1133519,
            "unit": "ns",
            "extra": "gctime=0\nmemory=420464\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 1474543,
            "unit": "ns",
            "extra": "gctime=0\nmemory=540112\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 2215099,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768576\nallocs=5899\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 8071163,
            "unit": "ns",
            "extra": "gctime=0\nmemory=342896\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 12422375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=485936\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 16116261,
            "unit": "ns",
            "extra": "gctime=0\nmemory=625248\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 24842636,
            "unit": "ns",
            "extra": "gctime=0\nmemory=895840\nallocs=5900\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 326924,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 460614,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 599130,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 862349,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 4941828.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 7493639,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 9654154.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 14676224.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "ebc0f71c7ce3f1860342e691d908560860020564",
          "message": "Multiply by delta_z for mass conservation testing",
          "timestamp": "2024-08-29T10:57:27-05:00",
          "tree_id": "051fc25e4b83bd2d9d6052f9473edc58ffa13dfa",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/ebc0f71c7ce3f1860342e691d908560860020564"
        },
        "date": 1724947997016,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 760872,
            "unit": "ns",
            "extra": "gctime=0\nmemory=299120\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 1137248,
            "unit": "ns",
            "extra": "gctime=0\nmemory=420464\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 1481574.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=540112\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 2340417,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768576\nallocs=5899\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 8087867,
            "unit": "ns",
            "extra": "gctime=0\nmemory=342896\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 12466594.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=485936\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 16143075,
            "unit": "ns",
            "extra": "gctime=0\nmemory=625248\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 24849460,
            "unit": "ns",
            "extra": "gctime=0\nmemory=895840\nallocs=5900\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 337592,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 476092,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 619870,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 890358,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 4947465.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 7498359,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 9659929,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 14692743.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "66f63783a2e72554c61e4ec7bdde7cba385ef698",
          "message": "upwind stencil conserves mass",
          "timestamp": "2024-08-30T12:45:31-05:00",
          "tree_id": "e19222cfb1be5992ce1eb0338ddb97318a4c1742",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/66f63783a2e72554c61e4ec7bdde7cba385ef698"
        },
        "date": 1725040880956,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 805815,
            "unit": "ns",
            "extra": "gctime=0\nmemory=299120\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 1206509,
            "unit": "ns",
            "extra": "gctime=0\nmemory=420464\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 1561627,
            "unit": "ns",
            "extra": "gctime=0\nmemory=540112\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 2353472,
            "unit": "ns",
            "extra": "gctime=0\nmemory=768576\nallocs=5899\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 8074597.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=342896\nallocs=2550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 12457555,
            "unit": "ns",
            "extra": "gctime=0\nmemory=485936\nallocs=3414\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 16109551,
            "unit": "ns",
            "extra": "gctime=0\nmemory=625248\nallocs=4386\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 24848146,
            "unit": "ns",
            "extra": "gctime=0\nmemory=895840\nallocs=5900\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 326676,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 459563,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 596547,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 859845,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 4981984.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 7526415,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 9659145,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 14726190.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=30720\nallocs=272\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "568ccc05385b992209f59ff5ca0aa178301021bc",
          "message": "Handle grids with negative dx",
          "timestamp": "2024-08-31T20:12:47-05:00",
          "tree_id": "f981284642a78a08ec35e736cdb6389b51be745e",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/568ccc05385b992209f59ff5ca0aa178301021bc"
        },
        "date": 1725154114055,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1386467,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580528\nallocs=5678\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2093100,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2708264,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086368\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4130768,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613392\nallocs=15240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12367164,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657584\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19050931,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24666080.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238000\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38062908.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843472\nallocs=15243\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 576882,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 828469,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 1067154.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1563782,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7444270,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11310447,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14563776.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22233877,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "fb929577825b25ab3d8a348721db1926b75561b0",
          "message": "Run demo for longer",
          "timestamp": "2024-09-03T11:54:46-05:00",
          "tree_id": "5ce342af0ef93f1460d4a1a2ba27e329b9560093",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/fb929577825b25ab3d8a348721db1926b75561b0"
        },
        "date": 1725383414313,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1179821.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=580560\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 1763303,
            "unit": "ns",
            "extra": "gctime=0\nmemory=846528\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 2299381,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1086368\nallocs=10485\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 3458444,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1613392\nallocs=15240\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12158171,
            "unit": "ns",
            "extra": "gctime=0\nmemory=657584\nallocs=5680\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 18719873,
            "unit": "ns",
            "extra": "gctime=0\nmemory=963424\nallocs=8165\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 24241618,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1238032\nallocs=10487\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 37407435,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1843472\nallocs=15243\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 527031,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 745498,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 966930,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 1404866.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 7406789.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 11267305,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 14517826,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 22191726.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "5ea8bddf474a0d8bd5f164e48100d0f4d5adc033",
          "message": "demo: reduce advection timestep",
          "timestamp": "2024-09-03T14:29:31-05:00",
          "tree_id": "5f1447860ba2ab9ff2dd9997f6b20c2a296e6d53",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/5ea8bddf474a0d8bd5f164e48100d0f4d5adc033"
        },
        "date": 1725392702794,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/510",
            "value": 1122731,
            "unit": "ns",
            "extra": "gctime=0\nmemory=511056\nallocs=5020\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/867",
            "value": 1831652,
            "unit": "ns",
            "extra": "gctime=0\nmemory=804368\nallocs=7771\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1020",
            "value": 2200079,
            "unit": "ns",
            "extra": "gctime=0\nmemory=949488\nallocs=9203\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1734",
            "value": 3619744,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1527216\nallocs=14456\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/510",
            "value": 10471238,
            "unit": "ns",
            "extra": "gctime=0\nmemory=577264\nallocs=5020\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/867",
            "value": 17716191,
            "unit": "ns",
            "extra": "gctime=0\nmemory=915664\nallocs=7770\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1020",
            "value": 20894936,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1079696\nallocs=9203\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1734",
            "value": 35492013.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1746224\nallocs=14457\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/510",
            "value": 467290,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/867",
            "value": 710598.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1020",
            "value": 845926,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1734",
            "value": 1330599,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/510",
            "value": 6336079,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/867",
            "value": 10592744,
            "unit": "ns",
            "extra": "gctime=0\nmemory=46768\nallocs=407\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1020",
            "value": 12483666.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1734",
            "value": 21079871,
            "unit": "ns",
            "extra": "gctime=0\nmemory=47088\nallocs=411\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "ctessum@gmail.com",
            "name": "Christopher Tessum",
            "username": "ctessum"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "0895f9ffe7bbcc4724ed0c37aba6d033d5c0bcd3",
          "message": "Merge pull request #30 from EarthSciML/newop\n\nrefactor advection",
          "timestamp": "2024-09-04T10:11:35-05:00",
          "tree_id": "ba1a53a42220964ac74ab0342e6a65a06ca33c4d",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/0895f9ffe7bbcc4724ed0c37aba6d033d5c0bcd3"
        },
        "date": 1725463633459,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/510",
            "value": 1423857,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7952\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/867",
            "value": 2419014,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10832\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1020",
            "value": 2844638,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12048\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1734",
            "value": 4845193,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17744\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/510",
            "value": 150405725,
            "unit": "ns",
            "extra": "gctime=0\nmemory=7952\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/867",
            "value": 255577944,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10832\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1020",
            "value": 300755664.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=12048\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1734",
            "value": 516681327,
            "unit": "ns",
            "extra": "gctime=0\nmemory=17744\nallocs=20\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/510",
            "value": 1426277,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/867",
            "value": 2421879,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1020",
            "value": 2847985,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1734",
            "value": 4836501,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/510",
            "value": 150537606.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/867",
            "value": 255426825,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1020",
            "value": 300696707,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1734",
            "value": 511276161,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "f9876aab31af06aec02ebf6b65411787c1960482",
          "message": "Update benchmarks",
          "timestamp": "2024-09-04T10:51:47-05:00",
          "tree_id": "bdbf78d6b152100a3ed06238eca5be3767acaff9",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/f9876aab31af06aec02ebf6b65411787c1960482"
        },
        "date": 1725468862849,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222",
            "value": 355000068,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719",
            "value": 89353936,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222",
            "value": 37398601943,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719",
            "value": 9374928531,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222",
            "value": 354519587.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719",
            "value": 89300514,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222",
            "value": 37318822807,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719",
            "value": 9374417827,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "a93ea925a4ddab2621d63a6d6f69c97764dac8d5",
          "message": "Fix typo",
          "timestamp": "2024-09-04T13:22:31-05:00",
          "tree_id": "8c24152791605434d5f1f5fe2a68c49a08c56da7",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/a93ea925a4ddab2621d63a6d6f69c97764dac8d5"
        },
        "date": 1725475445695,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 90367505.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 354729354,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9409437124,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37354809686,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 90369902,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 355028768,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9368421461,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37202681589,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "e591dabc2ec1228b4ea9af4429d4def704691b11",
          "message": "Add Puff model",
          "timestamp": "2024-09-15T18:06:18-05:00",
          "tree_id": "55e4cb1fac976b205cc93738740e717178784a63",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/e591dabc2ec1228b4ea9af4429d4def704691b11"
        },
        "date": 1726442758728,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 89374079,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 352079759.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9442293245,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37247695836,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 89511685,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 353063496,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9411361128,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37303257874,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "e0eb42ddd82d7e23708649b0f099f92a4ebd159e",
          "message": "Add Puff documentation",
          "timestamp": "2024-09-16T10:54:42-05:00",
          "tree_id": "5fa226120074e3996d6922e39bf02df6e1cee1a0",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/e0eb42ddd82d7e23708649b0f099f92a4ebd159e"
        },
        "date": 1726503262888,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 89448268,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 354836837,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9360117034,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37331659005,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 89199430,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 354034432,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9362285741,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37402011981,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "ctessum@gmail.com",
            "name": "Christopher Tessum",
            "username": "ctessum"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f8d541cb58b72ea8e7367ce05e2ed9d65897c26d",
          "message": "Merge pull request #34 from EarthSciML/dependabot/github_actions/contributor-assistant/github-action-2.6.0\n\nBump contributor-assistant/github-action from 2.4.0 to 2.6.0",
          "timestamp": "2024-09-23T08:53:47-05:00",
          "tree_id": "f38388abc354c4c559cc8adcb9064be9264f0b31",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/f8d541cb58b72ea8e7367ce05e2ed9d65897c26d"
        },
        "date": 1727100838162,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 94196736,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 368393196,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9438100786,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37621758413,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4416\nallocs=19\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 94320402.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 368348011,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9471164393,
            "unit": "ns",
            "extra": "gctime=0\nmemory=257552\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37543509431,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1013584\nallocs=21\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "bc7f3575e027034f763760d5b9382b1bc81cf6c6",
          "message": "Update puff model",
          "timestamp": "2024-10-12T11:10:29-05:00",
          "tree_id": "265c57a7713bd9f619c5806f88a063c9fe5b6b69",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/bc7f3575e027034f763760d5b9382b1bc81cf6c6"
        },
        "date": 1728751052443,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 90459687,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3776\nallocs=14\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 357728885,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3776\nallocs=14\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9233576420,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3776\nallocs=14\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36877560348,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3776\nallocs=14\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 89446106,
            "unit": "ns",
            "extra": "gctime=0\nmemory=256848\nallocs=15\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 352414783,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1012880\nallocs=15\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9250791065,
            "unit": "ns",
            "extra": "gctime=0\nmemory=256848\nallocs=15\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36757995243,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1012880\nallocs=15\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "a3fdb2665b677d1f19bbc914f334f4171c380bfc",
          "message": "Get Docs and Benchmarks working",
          "timestamp": "2024-10-29T18:41:59-05:00",
          "tree_id": "72b17d3019a10a18c6d6be5f5235dc9ae082911e",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/a3fdb2665b677d1f19bbc914f334f4171c380bfc"
        },
        "date": 1730251318034,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 132033372,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38574080\nallocs=2410658\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 528566292,
            "unit": "ns",
            "extra": "gctime=14080067\nmemory=153489728\nallocs=9592886\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9273050759,
            "unit": "ns",
            "extra": "gctime=0\nmemory=34514048\nallocs=2156906\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36770954388,
            "unit": "ns",
            "extra": "gctime=0\nmemory=137333312\nallocs=8583110\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 131341929.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38827152\nallocs=2410659\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 523671717,
            "unit": "ns",
            "extra": "gctime=13804003\nmemory=154498832\nallocs=9592887\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9258098037,
            "unit": "ns",
            "extra": "gctime=0\nmemory=34767120\nallocs=2156907\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36796489482,
            "unit": "ns",
            "extra": "gctime=0\nmemory=138342416\nallocs=8583111\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "1f173aab90ac5f1203b4819ec6ec49f3f68687ae",
          "message": "Fix Tests",
          "timestamp": "2024-10-29T20:55:03-05:00",
          "tree_id": "63f03985c5cb0d93653b0b7c1b434c40dfc5a7bd",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/1f173aab90ac5f1203b4819ec6ec49f3f68687ae"
        },
        "date": 1730254847401,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 134876480.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38574080\nallocs=2410658\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 524475558,
            "unit": "ns",
            "extra": "gctime=15327978\nmemory=153489728\nallocs=9592886\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9205273713,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38574080\nallocs=2410658\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36610141266,
            "unit": "ns",
            "extra": "gctime=0\nmemory=153489728\nallocs=9592886\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 134299974,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38827152\nallocs=2410659\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 519680673,
            "unit": "ns",
            "extra": "gctime=14744880\nmemory=154498832\nallocs=9592887\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9238916852,
            "unit": "ns",
            "extra": "gctime=0\nmemory=38827152\nallocs=2410659\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36649208491,
            "unit": "ns",
            "extra": "gctime=0\nmemory=154498832\nallocs=9592887\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "08ed9d3d6107541e8b8312b3e1b44dc956856dfa",
          "message": "Fix benchmarks",
          "timestamp": "2024-11-22T16:37:18-06:00",
          "tree_id": "63e8fb3b418c2a1b1a86753decc887899235958c",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/08ed9d3d6107541e8b8312b3e1b44dc956856dfa"
        },
        "date": 1732316384547,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 176536588.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 679485315,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9299827637,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37039802142,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 175656292,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 682799780,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9298236540,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36984932548,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "b960ee845fff6734fba8f59b99213d3e7817cf9f",
          "message": "Update puff demo",
          "timestamp": "2024-12-16T13:59:29-06:00",
          "tree_id": "dbeac537f3ab928d9976f22dc3fa5c05382a05eb",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/b960ee845fff6734fba8f59b99213d3e7817cf9f"
        },
        "date": 1734380470208,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 177435205,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 683686832,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9294206321,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37038935200,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 178993094.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 690558076,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9256481249,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 37020005384,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "fb17c02c39ab50716997754120113d4da8aa451d",
          "message": "Check for state array shape",
          "timestamp": "2025-02-19T16:19:16-06:00",
          "tree_id": "918b4fc17533db75b8ebecf255aef428f01d6248",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/fb17c02c39ab50716997754120113d4da8aa451d"
        },
        "date": 1740004866099,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 109373998,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 411670278,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9238264873,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18273776\nallocs=570947\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36873709893,
            "unit": "ns",
            "extra": "gctime=0\nmemory=72707504\nallocs=2272001\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 109761000.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 413077141,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9247208998,
            "unit": "ns",
            "extra": "gctime=0\nmemory=18526528\nallocs=570948\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36843470875,
            "unit": "ns",
            "extra": "gctime=0\nmemory=73716288\nallocs=2272002\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
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
          "id": "c059894a7515207a28c07552352d87742f466279",
          "message": "Update doc compat",
          "timestamp": "2025-02-24T10:18:17-06:00",
          "tree_id": "c1e0d26397ffc2046e1fed393b32f37e152a80cf",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/c059894a7515207a28c07552352d87742f466279"
        },
        "date": 1740415266234,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 103565279,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10409552\nallocs=317201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 386711432,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41406544\nallocs=1262231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9246164511,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10409552\nallocs=317201\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36790739496,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41406544\nallocs=1262231\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.625 x 0.5 (N=31719)",
            "value": 102409786,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10408592\nallocs=317200\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/0.3125 x 0.25 (N=126222)",
            "value": 381659628.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41405584\nallocs=1262230\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.625 x 0.5 (N=31719)",
            "value": 9250236316,
            "unit": "ns",
            "extra": "gctime=0\nmemory=10408592\nallocs=317200\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/0.3125 x 0.25 (N=126222)",
            "value": 36800688960,
            "unit": "ns",
            "extra": "gctime=0\nmemory=41405584\nallocs=1262230\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}