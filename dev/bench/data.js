window.BENCHMARK_DATA = {
  "lastUpdate": 1723560325895,
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
          "id": "ff5ceb88c5f81c3f85332297319a53f58f29869e",
          "message": "Performance optimizations",
          "timestamp": "2024-08-13T23:30:25+09:00",
          "tree_id": "406256ce5dbcc27f94513323e27f1a879c831898",
          "url": "https://github.com/EarthSciML/EnvironmentalTransport.jl/commit/ff5ceb88c5f81c3f85332297319a53f58f29869e"
        },
        "date": 1723560325413,
        "tool": "julia",
        "benches": [
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/594",
            "value": 1536563,
            "unit": "ns",
            "extra": "gctime=0\nmemory=441776\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/918",
            "value": 2327778,
            "unit": "ns",
            "extra": "gctime=0\nmemory=620240\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1188",
            "value": 3063754.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=763488\nallocs=4550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/l94_stencil/1836",
            "value": 4650557,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1102848\nallocs=6730\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/594",
            "value": 12544366,
            "unit": "ns",
            "extra": "gctime=0\nmemory=505648\nallocs=2512\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/918",
            "value": 19359060,
            "unit": "ns",
            "extra": "gctime=0\nmemory=718224\nallocs=3614\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1188",
            "value": 25077562,
            "unit": "ns",
            "extra": "gctime=0\nmemory=890400\nallocs=4550\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/out-of-place/ppm_stencil/1836",
            "value": 38728808,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1297488\nallocs=6729\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/594",
            "value": 1387273,
            "unit": "ns",
            "extra": "gctime=0\nmemory=189728\nallocs=388\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/918",
            "value": 2106237.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=238944\nallocs=393\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1188",
            "value": 2784665.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=271584\nallocs=393\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/l94_stencil/1836",
            "value": 4245293,
            "unit": "ns",
            "extra": "gctime=0\nmemory=349344\nallocs=393\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/594",
            "value": 15722104.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=189728\nallocs=388\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/918",
            "value": 24494425,
            "unit": "ns",
            "extra": "gctime=0\nmemory=238944\nallocs=393\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1188",
            "value": 31431914,
            "unit": "ns",
            "extra": "gctime=0\nmemory=271584\nallocs=393\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Advection Simulator/in-of-place/ppm_stencil/1836",
            "value": 48673693,
            "unit": "ns",
            "extra": "gctime=0\nmemory=349024\nallocs=389\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}