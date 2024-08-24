window.BENCHMARK_DATA = {
  "lastUpdate": 1724465577375,
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
      }
    ]
  }
}