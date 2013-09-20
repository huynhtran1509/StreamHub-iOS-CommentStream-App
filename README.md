CommentStream (example)
=======================

This is a basic sample app that demonstrates how to use some of the services
provided by StreamHub-iOS-SDK, a native client for Livefyre API. It supports
viewing a collection and streaming comments in real-time. The app uses
OHAttributedLabel to display comments using rich formatting in a way that is
compatible with iOS 6.x versions.

Also see the official repository for the StreamHub-iOS-SDK:
https://github.com/Livefyre/StreamHub-iOS-SDK

# Getting Started

You will need to clone StreamHub-iOS-SDK first:

    git clone -b xavier_7013 git@github.com:Livefyre/StreamHub-iOS-SDK.git
    cd StreamHub-iOS-SDK/examples/
    git clone git@github.com:Livefyre/StreamHub-iOS-Example-App.git CommentStream
    cd CommentStream
    pod install
    open CommentStream.xcworkspace

Use `CommentStream.xcworkspace` to open the project instead of
`CommentStream.xcproject`

# Requirements

At present, StreamHub-SDK v0.2.0 requires iOS 6.0 or later (mostly due to
external dependencies). If you would like to use this SDK with iOS versions
prior to 6.0, please contact Livefyre and we'll be happy to help.

# License

This software is licensed under the MIT License.

The MIT License (MIT)

Copyright (c) 2013 Livefyre

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

