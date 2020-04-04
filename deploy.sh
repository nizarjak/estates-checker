#! /bin/bash

echo "xcodebuild -scheme estates-checker archive -archivePath executable"
xcodebuild -scheme estates-checker archive -archivePath estates-checker

echo "rm -fdr executable"
rm -fdr executable/*

echo "cp -r estates-checker.xcarchive/Products/usr/local/* usr/local/"
cp -r estates-checker.xcarchive/Products/usr/local/* usr/local/

echo "rm -fdr estates-checker.xcarchive"
rm -fdr estates-checker.xcarchive

echo "git add ."
git add .

echo "git commit -m \"Deploy\""
git commit -m "Deploy"

echo "git push"
git push
