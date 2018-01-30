title: RTB 广告优化 ---- 在线平滑投放实现 
date: 2017-02-10 09:13:16
tags: [平滑投放, RTB, 广告优化]
categories: 论文阅读
---

## 概述 & 介绍

### 为什么做平滑投放

- 广告主通过采买一定量的展示量尽可能的触达更多的用户，产生对应的互动
- 在一段时间内，平滑的消费预算为了可以触达更广范围内的用户，并且持续产生影响


### 实时广告优化目标


 - 在有限的预算内实现优化目标最大化
 - 尽可能的降低 CPC (cost per click) CPA (const per action)
 - 尽可能的提升 CTR (click through rate) AT (action through rate)

### 解决的问题

- 防止过早的消费完预算
- 避免突发性的消费
- 避免在流量峰值上投放过多的广告，保证广告的可持续影响和触达范围

### 解决问题方式

- 基于历史指标分布通过选择高质量展示和调整竞价来实现时间区间预算最佳分配

### 实时广告优化的挑战

- 低延迟，高吞吐量
- 优化参考指标信息延迟，比如反馈信息延迟、收集的点击日志处理延迟、或者关联的广告展示对应的交互可能几天后才会产生等
- 对于非搜索类的广告转化低，因此在评估历史的指标时方差特别大


## 背景与相关工作

### 问题

- 过早的消费完预算

![](/image/papers/real_time_bid_optimization/figure_1_a.png)

- 预算消费波动太大

![](/image/papers/real_time_bid_optimization/figure_1_b.png)


### 解决

通常解决办法是采用平均预算的方式如图所示：

![](/image/papers/real_time_bid_optimization/figure_1_c.png)

但是这个有两个问题：

 - 流量问题
 
 比如通过定向条件过滤后的流量上午多余下午，按照平均预算的策略可能上午还有一定的流量空余，而下午由于流量小可能要强制投放一些效果差的广告
 
 通过和流量关联来解决这个问题，如图：
 
 ![](/image/papers/real_time_bid_optimization/figure_1_d.png)
 
 
 - 效果问题
 
 和流量问题类似，如果平均预算策略可能会导致优质流量时段没有预算大量投放，所以通过和效果来关联解决这个问题，如图：
 
 ![](/image/papers/real_time_bid_optimization/figure_1_e.png)
 
 不过这种方式有一个潜在的问题就是当一个小的区间质量特别高会出现预算波动的问题，违背了平滑投放的限制,平衡流量和效果两个指标有一定的挑战，这个论文就是解决这两个指标的同步问题
 
 
为了实现平滑投放，我们将总体的日常预算 `B` 按时间空档序列分配为 `{b1,....,bt}` 其中 `bt` 就是时间空档 `t` 的预算,接下来就是我们通过不同的分配 `bt` 策略来选择出高质量的展示流量, 综上所述可以总结为如下数学问题：


 ![](http://latex.codecogs.com/gif.latex?maximize%20%5C%20%5C%20%5C%20%5C%20%5C%20%5Csum_%7Bn%7D%5E%7Bi%3D1%7Dv_%7Bi%7Dx_%7Bi%7D)

 ![](http://latex.codecogs.com/gif.latex?subject%20%5C%20%5C%20to%20%5C%20%5C%20%5C%20%5C%20%5Csum_%7Bj%5Cin%20%5Cmathbb%7BI%7D_t%7Dc_%7Bj%7Dx_%7Bj%7D%20%5Cleq%20b_%7Bt%7D%20%5C%20%5C%20%5C%20%5C%20%5C%20%5C%20%5Cforall%20_%7Bt%7D%20%5Cin%20%5Cleft%20%5C%7B%201%2C....%2CT%20%5Cright%20%5C%7D)

[](maximize      \ \ \ \ \  \sum_{n}^{i=1}v_{i}x_{i})

[](subject \  \  to \ \ \ \ \sum_{j\in \mathbb{I}_t}c_{j}x_{j} \leq b_{t} \ \ \ \ \ \ \forall _{t} \in \left \{ 1,....,T \right \})

这块的 ![](http://latex.codecogs.com/gif.latex?%5Cmathbb%7BI%7D_t) 代表在时间空档 `t` 中的所有广告请求集合。当广告请求 `i` 请求时，算法必须要给出 ![](http://latex.codecogs.com/gif.latex?x_i) , 在优化过程中也需要给出一个投放价格 ![](http://latex.codecogs.com/gif.latex?%5Cwidehat%7Bc_i%7D) 预估值，这个并不是真正的消费预算，因为一般的 ADX 都是第二定价，所以 ![](http://latex.codecogs.com/gif.latex?%5Cwidehat%7Bc_i%7D%3Dc_i%20&plus;%20%5Cepsilon%20_i) , 其中 ![](http://latex.codecogs.com/gif.latex?c_i) 才是真正的消费价格。

### 相关解决办法

对于表达式一是典型的线性回归问题，对于 `Zhou et al. [21] modeled the budget constrained bidding optimization problem as an online knapsack problem` 中采用了一个简单的策略，基于一个指数函数和以前的预算相关联来完成广告高质量的筛选， 随着迭代，这个方法选择的质量越来越高，但是这个算法的前提是有无限的广告供应，这个对于 RTB 竞价广告定向后的广告量来说是不可能实现的。

对于 `Babaio↵ et al. [5] formulated the problem of dynamic bidding price` 中提到的使用 多臂老虎机， 采用这个策略的置信区间的上间来优化价格。这个方法不需要任何历史分布，但是多臂老虎机需要快速的反馈数据, 而对于 RTB 交易的展示广告这些指标有很大的延迟

对于 `Agrawal et al. [3] proposed an general online linear pro- gramming algorithm to solve many practical online prob- lems` 首先采用标准线性回归的方法基于目前系统的数据计算出对偶最优解。问题是每个广告请求到达时， ![](http://latex.codecogs.com/gif.latex?v_i) (决定是否展示的变量0， 1) 和  ![](http://latex.codecogs.com/gif.latex?c_i) 真正的值是未知的，如果采用统计预估的方式计算的话，每次都需要重新计算对偶解，这样对于实时竞价的广告来说会产生巨大的计算量

## 在线广告优化

通过出价方式将优化的广告系列分为：

- 固定出价的 CPM 广告
- 动态出价的 CPM 广告（dcpm）

对于固定出价的 CPM 广告关注的目标指标是 CTR 、AR , 对于动态出价的 CPM 关注的是 ecpc 和 ecpa ，不管是什么类型的广告，优化目标可以总结为如下：

![](http://latex.codecogs.com/gif.latex?min%20%5C%20%5C%20%5C%20-CTR%2C%20-AR%20%2CeCPC%20%5C%20or%20%5C%20eCPA)

![](http://latex.codecogs.com/gif.latex?s.t.%20%5C%20%5C%20%5C%20%7C%5Csum_%7Bt%7D%5E%7BT%7Ds%28t%29%20-%20B%20%7C%20%5Cleq%20%5Cvarepsilon)

![](http://latex.codecogs.com/gif.latex?%5C%20%5C%20%5C%20%5C%20%5C%20%5C%20%5C%20%7Cs%28t%29%20-%20b_t%7C%20%5Cleq%20%5Cdelta%20_t%20%5C%20%5C%20%5C%20%5C%20%5C%20%5C%20%5Cforall%20%5Cin%20%5Cleft%20%5C%7B%201%2C.....%2CT%20%5Cright%20%5C%7D)

![](http://latex.codecogs.com/gif.latex?eCPM%20%5Cleq%20M)

首先是对整体日消费额度的限制，其中 `s(t)` 表示在时间空档 `t` 中消费的额度， 第二个约束是根据额度 ![](http://latex.codecogs.com/gif.latex?b_t) 在一个时间空档中进行分配达到平滑投放，最后一个是要求平均出价 eCPM 要小于最大出价限度 `M`

根据上述构想，我们需要优化的参数是 ![](http://latex.codecogs.com/gif.latex?b_t) ， 因为日消费额度 `B` 和 最大出价限度 `M` 是广告主自行设定。

[](min \ \ \ -CTR, -AR ,eCPC \ or \ eCPA)
[](s.t. \ \ \ |\sum_{t}^{T}s(t) - B | \leq  \varepsilon )
[](\ \ \ \  \ \ \  |s(t) - b_t| \leq \delta _t \ \ \ \ \ \ \forall \in \left \{ 1,.....,T \right \})
[](eCPM \leq M)

### 平滑投放预算计算

采用将整天拆分为 T 个时间空档，每个时间空档每个系列广告分配一定的预算， 在一个时间空档 `t` 中消费的预算和获取到的展示量是成比例的，因为我们假设在一个时间空档中每个独立的展示的价格大约是一致的，这个在实际应用中价格的方差是很小的，所以可以假设在一个 slot 中价格是一个常量。

对于每个广告系列我们分配一个竞价率，竞价率的定义就是参与竞价的请求量 (bids) 和总请求量(reqs)的比值, 通过表达式 (1) 我们可以推算出竞价率的另外一种表达式：

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20s%28t%29%20%3D%20%5Csum_%7Bj%5Cin%20%5Cmathbb%7BI%7D_t%7Dc_jx_j%20%5Cpropto%20reqs%28t%29%20%5Cfrac%7Bbids%28t%29%7D%7Breqs%28t%29%7D%5Cfrac%7Bimps%28t%29%7D%7Bbids%28t%29%7D)

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20%5Cpropto%20reqs%28t%29%5Ccdot%20pacing%5C_rate%28t%29%5Ccdot%20win%5C_rate%28t%29)

[](s(t) = \sum_{j\in \mathbb{I}_t}c_jx_j \propto reqs(t) \frac{bids(t)}{reqs(t)}\frac{imps(t)}{bids(t)} 
\propto reqs(t)\cdot pacing\_rate(t)\cdot win\_rate(t))

接下来我们通过获取到前一个 slot 的竞价率和消耗来调整当前的竞价率， 通过上述公式递归得出：

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20%5Cfrac%7Breqs%28t%29%5Ccdot%20pacing%5C_rate%28t%29%5Ccdot%20win%5C_rate%28t%29%20%7D%7Breqs%28t&plus;1%29%5Ccdot%20pacing%5C_rate%28t&plus;1%29%5Ccdot%20win%5C_rate%28t&plus;1%29%20%7D%20%3D%20%5Cfrac%7Bs%28t%29%7D%7Bs%28t&plus;1%29%29%7D)

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20%5Cpropto%20pacing%5C_rate%28t&plus;1%29%20%3D%20pacing%5C_rate%28t%29%5Cfrac%7Bs%28t&plus;1%29%5Ccdot%20reqs%28t%29%5Ccdot%20win%5C_rate%28t%29%20%7D%7Bs%28t%29%5Ccdot%20reqs%28t&plus;1%29%5Ccdot%20win%5C_rate%28t&plus;1%29%20%7D)

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20%5Cpropto%20pacing%5C_rate%28t&plus;1%29%20%3D%20pacing%5C_rate%28t%29%5Cfrac%7B%7B%5Ccolor%7BRed%7D%20b_%7Bt&plus;1%7D%7D%5Ccdot%20reqs%28t%29%5Ccdot%20win%5C_rate%28t%29%20%7D%7Bs%28t%29%5Ccdot%20reqs%28t&plus;1%29%5Ccdot%20win%5C_rate%28t&plus;1%29%20%7D)

通过上述转化 如果要求得一个竞价率 `pacing_rate(t+1)` 需要通过上次的请求量、竞价成功率、消耗、本次竞价成功率、本次请求量、本次预算来得出， 其中上次的数据是已知的，本次竞价成功率、本次请求可以通过历史数据预测，目前需要确定的数据指标只有 ![](http://latex.codecogs.com/gif.latex?b_{t+1}), 只要求出该值对应的竞价率就会得出

假设我们采用同样的竞价率的策略，那么计算 ![](http://latex.codecogs.com/gif.latex?b_{t+1}) 公式如下：

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20b_%7Bt&plus;1%7D%5Eu%20%3D%20%5Cleft%20%28%20B%20-%20%5Csum_%7Bm%3D1%7D%5E%7Bt%7D%20s%28m%29%5Cright%20%29%5Cfrac%7BL%28t&plus;1%29%7D%7B%5Csum_%7Bm%3Dt&plus;1%7D%5E%7BT%7DL%28m%29%29%7D)

其中 `L(t+1)` 代表第 `t+1` 个时间空档的时间长度， 如果每个时间空档长度相同那么该表达式可以转化为：

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20b_%7Bt&plus;1%7D%5Eu%20%3D%20%5Cleft%20%28%20B%20-%20%5Csum_%7Bm%3D1%7D%5E%7Bt%7D%20s%28m%29%5Cright%20%29%5Cfrac%7B1%7D%7BT-t%7D)


**但是在上面也讨论了同竞价率的平滑策略的问题，所以我们需要改善策略**， 我们需要在一个 slot 内消耗固定的额度来尽可能的提升转化，我们需要构建一个概率密度函数描述某个转化指标在在单个时间空档发生的概率密度： `p0,....pT` 假设一天有 T 个时间空档，并且 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Csum_%7Bt%7D%5E%7BT%7Dp_t%20%3D%201) 。通过加入转化指标的因子来尽可能的提升转化率，加入转化因子后的理想的消耗计算方法变为：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20b_%7Bt&plus;1%7D%5Ep%20%3D%20%5Cleft%20%28%20B-%5Csum_%7Bm%3D1%7D%5E%7Bt%7D%20s%28m%29%5Cright%20%29%5Cfrac%7Bp_%7Bt&plus;1%7D%5Ccdot%20L%28t&plus;1%29%7D%7B%5Csum_%7Bm%3Dt&plus;1%7D%5E%7BT%7Dp_m%5Ccdot%20L%28m%29%7D)

如果时间空档相同则：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20b_%7Bt&plus;1%7D%5Ep%20%3D%20%5Cleft%20%28%20B-%5Csum_%7Bm%3D1%7D%5E%7Bt%7D%20s%28m%29%5Cright%20%29%5Cfrac%7Bp_%7Bt&plus;1%7D%7D%7B%5Csum_%7Bm%3Dt&plus;1%7D%5E%7BT%7Dp_m%7D)

在实践中可能会遇到 ![](http://latex.codecogs.com/gif.latex?p_j) 为 0 的时候，这将会导致没有预算来投放，为了避免这种情况的发送我们可以结合平均竞价率策略和该策略混合使用。

**概率密度相关计算**

 ![](http://latex.codecogs.com/gif.latex?p_j) 计算可以通过 当前时间空档转化个数除以整天转化个数计算出当前空档的概率分布密度，依次类推
 

### 选择高质量广告请求 --- 固定 CPM 模式

对于 固定 CPM 模式的广告，出价永远是固定  ![](http://latex.codecogs.com/gif.latex?c^*) , 我们需要做的优化就是如何在当前价格、当前竞价率条件下选择出高质量的广告。当广告请求到达时我们并不知道这个广告的真实价值，我们需要借助 CTR 或者 AR 预估系统来预估一个价值。

为了满足平滑策略可知：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20imps%5E*%28t%29%20%3D%20%5Cfrac%7Bs%28t%29%7D%7Bc%5E*%7D)

通过竞价胜率可得：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20reqs%5E*%28t%29%20%3D%20%5Cfrac%7Bimps%5E*%28t%29%7D%7Bwin%5C_rate%28t%29%7D)

同上，采用竞价率可以预估出来本时间区间需要接受的请求数 :

![](http://latex.codecogs.com/gif.latex?%5Cdpi%7B150%7D%20reqs%5E*%28t%29%20%3D%20%5Cfrac%7Bbids%5E*%28t%29%7D%7Bpacing%5C_rate%28t%29%29%7D)

通过每个广告系列的历史数据构建一个指数直方图，如图：

![](/image/papers/real_time_bid_optimization/figure_2.png)

其中分布函数 ![](http://latex.codecogs.com/gif.latex?q_t(x)) 代表在 时间空档 t 中 CTR 或者 AR 是 x 的请求个数， 我们的在线算法其实就是要在时间空档 t 中找一个阀值 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Ctau%28t%29) 来过滤满足平滑策略但 CTR 或者 AR 低于该阀值的请求，所以该阀值可以表示为：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Ctau%28t%29%20%3D%20arg%20%5C%20min_x%20%7C%20%5Cint_%7Bx%7D%5E%7B1%7Dq_t%28x%29dx%20-%20reqs%5E*%28t%29%7C)

在实践中由于 CTR 或者 AR 分布不需要经常计算，如果 ![](http://latex.codecogs.com/gif.latex?q_t(x))  不是很接近当前请求分布时，会导致当前时间空档的阈值震荡。由于 ![](http://latex.codecogs.com/gif.latex?q_t(x)) 分布时通过历史数据生成，所以产生这种情况很正常，为了避免这种情况，我们将阈值改为一个可信区间。首先我们通过计算这个阈值的平均值和方差，并且通过中心极限定理推断  ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Ctau%28t%29) 是满足高斯分布的，所以可信区间通过如下公式计算：

上限：![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cmu_%5Ctau%20%28t%29%20&plus;%20%5Cgamma%20%5Cfrac%7B%5Csigma%20_%5Ctau%20%28t%29%29%7D%7B%5Csqrt%7Bd%7D%7D)

下限：![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cmu_%5Ctau%20%28t%29%20-%20%5Cgamma%20%5Cfrac%7B%5Csigma%20_%5Ctau%20%28t%29%29%7D%7B%5Csqrt%7Bd%7D%7D)

其中 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cmu_%5Ctau%20%28t%29) 为阈值平均值，![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Csigma%20_%5Ctau%20%28t%29) 为阈值方差， `d` 为计算该分布函数的历史数据的天数

对于常数 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cgamma) = 1.96 时计算的是 95%的可信区间

**这个阈值的上下限在每个时间空档都会更新**

和平滑策略合并在一块可以总结为：

- 当预测的 CTR 或者 AR 的值 大于阈值的上限直接参与竞价
- 当预测的 CTR 或者 AR 的值 介于阈值的上下限之间，则采用正常的竞价率计算竞价
- 当预测的 CTR 或者 AR 的值 小于阈值的下限则不参与竞价


### 选择高质量广告请求 --- 动态 CPM 模式

对于 dcpm 类型的广告，是通过动态的调整价格，来满足平滑预算。并且竞价率 (pacing_rate) 控制参与竞价的频率，如果竞价价格不是很高可能会在公开竞价过程中失败，如果太高可能会增加预算，即使是第二定价的情况下也一样。为了调整竞价价格，我们定义了两个阈值： ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%200%20%5Cleq%20%5Cbeta_1%20%5Cleq%20%5Cbeta_2%20%5Cleq%201) , 我们可以通过竞价率分为三个区域： 

- 安全区： ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20pacing%5C_rate%28t%29%20%5Cleq%20%5Cbeta_1) 在该区域一般由于受众定向比较宽泛的原因很容易消耗预算
- 临界区： ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cbeta_1%20%5Cleq%20pacing%5C_rate%28t%29%20%5Cleq%20%5Cbeta_2) 在该区域内表示投放正常
- 危险区：![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cbeta_2%20%5Cleq%20pacing%5C_rate%28t%29) 表示很难找到合适的展示广告或者很难竞价成功

后面我们分开讨论：

典型的 dcpm 是为了完成某个目标值 G 的，通常是 CPA(eCPA) ，我们可以用这个目标值来定义一个底价即： ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cmu_i%20%3D%20AR%20%5Ctimes%20G), 其中 `AR` 是通过预估模块计算出的本次请求的 AR 值。

对于临界区的直接提交这个价格竞价即可

对于安全区我们需要通过第二定价来不断的学习一个最优的价格，因为竞价出价和第二价格之间的差异正好反映了当前展示的广告质量和我们预估的展示广告质量之间差异。比如我们提交的竞价价格 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cwidehat%7Bc_i%7D) 和实际支付的第二定价 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%7Bc_i%7D) , 我们可以构建一个竞价价格和定价价格之间的差值比例 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Ctheta%20%3D%20%5Cfrac%7Bc_i%7D%7B%5Cwidehat%7Bc_i%7D%7D), 那么在安全区我们提交的价格计算方式为： ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cwidehat%7Bc_i%7D%20%3D%20%5Ctheta%20*%20%5Cmu_i), 很显然通过这种方式在提高优化指标的同时也在影响消耗，但是由于在安全区所以问题不大

最后是危险区，对于处于危险区域的广告系列，有以下两个原因：

- 由于受众定向条件太过严格，导致没有太多的竞价机会
- 竞价的价格太低导致胜率太低

对于第一种情况没有办法解决，但是第二种情况可以通过调整价格的办法解决

比如设定的最大出价 `C` ，加价系数 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Crho%5E*%20%5Cgeq%201) ，通过将 加价系数和竞价率建立负相关关系来解决，计算方式如下：

![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Crho%5E*%20%3D%201%20&plus;%20%5Cfrac%7B%5Cfrac%7BC%7D%7Bc%5E*%7D%20-%201%7D%7B1%20-%20%5Cbeta_2%7D%28pacing%5C_rate%28t%29%20-%20%5Cbeta_2%29)

通过将差价比例与 竞价率差价比例相乘来调整价格系数

最终通过 ![](http://latex.codecogs.com/gif.latex?%5Cinline%20%5Cdpi%7B150%7D%20%5Cwidehat%7Bc_i%7D%20%3D%20%5Crho%5E*%5Cmu_i) 来出价

## CTR 和 AR 预估

## 参考资料

- [置信区间](https://www.zhihu.com/question/26419030)
- [中心极限定理](https://www.zhihu.com/question/22913867)
- [Real Time Bid Optimization with Smooth Budget Delivery in Online Advertising](https://dl.acm.org/citation.cfm?id=2501979)
