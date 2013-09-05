StreamHub-iOS-Example-App
=========================

This is a basic sample app that demonstrates how to use some of the services provided by
StreamHub-iOS-SDK, a native client for Livefyre API. It supports viewing a collection and
streaming comments in real-time.

Also see the official repository for the StreamHub-iOS-SDK: https://github.com/Livefyre/StreamHub-iOS-SDK

# Getting Started

You will need to clone StreamHub-iOS-SDK first:

    git clone -b xavier_7013 git@github.com:Livefyre/StreamHub-iOS-SDK.git
    cd StreamHub-iOS-SDK
    git clone git@github.com:Livefyre/StreamHub-iOS-Example-App.git CommentStream
    cd CommentStream
    pod install
    open CommentStream.xcworkspace

Use `CommentStream.xcworkspace` to open the project instead of `CommentStream.xcproject`

# Requirements

At present, StreamHub-SDK v0.2.0 requires iOS 6.0 (mostly due to external dependencies). If you
would like to use this SDK with iOS versions prior to 6.0, please contact Livefyre and we'll 
be happy to help.

# License

Copyright (C) 2013 Livefyre

Distributed under the MIT License.
