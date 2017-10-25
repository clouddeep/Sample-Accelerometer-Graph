# Sample-Accelerometer-Graph
Study real time chart from sample code of Apple. This code is too old for run & build on Xcode 9.0 so that I re-construct it.

# Real Time Flow
- Accelerometer comes to the MainViewController
- Send data to GraphView
- Convert data to a piece of layer representing a part of chart(GraphViewSegment)
- Store GraphViewSegment in an array
- Every time addX:y:z: called, move the x coordinate of layer of all GraphViewSegment by 1

# GraphView
- GraphViewSegment: part of chart (size: width 32, height 112)
- GraphTextView: drawing text in front of chart

A complete GraphViewSegment is deteremined by 64 points which comes from accelerometer data. Add new GraphViewSegment or recycle an old GraphViewSegment is up to whether the last GraphViewSegment is visible, if not, move it to the first place and reassign new data to it.

The effect of real time movement is made at every time addX:y:z: called.
