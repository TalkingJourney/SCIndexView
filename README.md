# 效果
微信效果图：
![defalut style.gifo动](https://github.com/TalkingJourney/SCIndexView/blob/master/SCIndexViewDemo/Snapshots/demo_default.gif)
toast效果图：
![center toast style.gifo动](https://github.com/TalkingJourney/SCIndexView/blob/master/SCIndexViewDemo/Snapshots/demo_center_toast.gif)

# 功能及优点
主要功能及优点如下：
1. 当滑动UITableView列表时，索引视图的索引位置会跟着移动；
2. UITableView和SCIndexView之间手势和事件不冲突，操作其中一个视图，另一个视图失效；
3. 当滑动索引视图时，会有指示器或者toast提示当前索引位置；
4. 索引视图可以从sc_startSection开始，忽略前面section；
5. 可以任意定制指示器、toast、索引视图的大小，文字颜色大小，间距等UI样式；
6. 当第一个数据为UITableViewIndexSearch时，自动添加放大镜图标。

# 使用方法
可以通过CocoaPods导入，支持iOS7及以上。

pod 'SCIndexView'

1. 创建SCIndexViewConfiguration对象，这个对象用来控制索引的UI样式；
2. 设置UITableView对象的 sc_translucentForTableViewInNavigationBar 和 sc_indexViewConfiguration；
3. 再设置UITableView对象的索引数据源。
不用再关心SCIndexView视图本身，直接在UITableView上设置即可。

```
SCIndexViewConfiguration *indexViewConfiguration = [SCIndexViewConfiguration configuration];
tableView.sc_indexViewConfiguration = indexViewConfiguration;
tableView.sc_translucentForTableViewInNavigationBar = YES;
tableView.sc_indexViewDataSource = indexViewDataSource;
```

# 结束
如果大家有什么想法的话，可以向我反馈。如果大家喜欢的话，也可以通过star来鼓励下我，感谢大家捧场。
