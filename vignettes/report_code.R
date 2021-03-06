## ---- library
library(quokar)
library(quantreg)
library(ggplot2)
library(gridExtra)
library(purrr)
library(tidyr)
library(dplyr)
library(robustbase)


## ---- high-lm1
x <- sort(runif(100))
y1 <- 40*x + x*rnorm(100, 0, 10)
df <- data.frame(y1, x)
add_outlier <- data.frame(y1 = c(60,61,62), x = c(0.71, 0.73,0.75))
df_o <- rbind(df, add_outlier)
model1 <- lm(y1 ~ x, data = df)
model2 <- lm(y1 ~ x, data = df_o)
coeff_lm <- c(model1$coef[2], model2$coef[2])
inter_lm <- c(model1$coef[1], model2$coef[1])
flag <- c("without-outlier", "with-outlier")
line_lm <- data.frame(coeff_lm, inter_lm, flag)
ggplot(df_o, aes(x = x, y = y1)) +
  geom_point(alpha = 0.1) +
  geom_abline(data = line_lm, aes(intercept = inter_lm,
                                  slope = coeff_lm, colour = flag))

## ---- high-rq1
coef1 <- rq(y1 ~ x, tau = c(0.1, 0.5, 0.9), data = df, method = "br")$coef
rq_coef1 <- data.frame(intercept = coef1[1, ], coef = coef1[2, ],
                       tau_flag =colnames(coef1))

coef2 <- rq(y1 ~ x, tau = c(0.1, 0.5, 0.9),data = df_o, method = "br")$coef
rq_coef2 <- data.frame(intercept = coef2[1, ], coef = coef2[2, ],
                       tau_flag =colnames(coef2))
ggplot(df_o) +
  geom_point(aes(x = x, y = y1), alpha = 0.1) +
  geom_abline(data = rq_coef1, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))+
  geom_abline(data = rq_coef2, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))


## ---- low-lm1
x <- sort(runif(100))
y2 <- 40*x + x*rnorm(100, 0, 10)
df <- data.frame(y2, x)
add_outlier <- data.frame(y2 = c(1,2,3), x = c(0.71, 0.73,0.75))
df_o <- rbind(df, add_outlier)
model1 <- lm(y2 ~ x, data = df)
model2 <- lm(y2 ~ x, data = df_o)
coeff_lm <- c(model1$coef[2], model2$coef[2])
inter_lm <- c(model1$coef[1], model2$coef[1])
flag <- c("without-outlier", "with-outlier")
line_lm <- data.frame(coeff_lm, inter_lm, flag)
ggplot(df_o, aes(x = x, y = y2)) +
  geom_point(alpha = 0.1) +
  geom_abline(data = line_lm, aes(intercept = inter_lm,
                                  slope = coeff_lm, colour = flag))

## ---- low-rq1

coef1 <- rq(y2 ~ x, tau = c(0.1, 0.5, 0.9), data = df, method = "br")$coef
rq_coef1 <- data.frame(intercept = coef1[1, ], coef = coef1[2, ], tau_flag = colnames(coef1))

coef2 <- rq(y2 ~ x, tau = c(0.1, 0.5, 0.9), data = df_o, method = "br")$coef
rq_coef2 <- data.frame(intercept = coef2[1, ], coef = coef2[2, ], tau_flag = colnames(coef2))
ggplot(df_o) +
  geom_point(aes(x = x, y = y2), alpha = 0.1) +
  geom_abline(data = rq_coef1, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))+
  geom_abline(data = rq_coef2, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))

## ---- move-y1
x <- sort(runif(100))
y <- 40*x + x*rnorm(100, 0, 10)
selectedX <- sample(50:100,5)
y2<- y
y2[selectedX] <- x[1:5]*rnorm(5, 0, 10)
y3 <- y2
y3[selectedX] <- y2[selectedX] - 10
y4 <- y3
y4[selectedX] <- y3[selectedX] - 10
df <- data.frame(x, y, y2, y3, y4)
df_m <- df %>% gather(variable, value, -x)
ggplot(df_m, aes(x = x, y=value)) +
  geom_point(alpha = 0.5) +
  xlab("x") +
  ylab("y") +
  facet_wrap(~variable, ncol=2, scale = "free_y") +
  geom_quantile(quantiles = seq(0.1, 0.9, 0.1), colour = "purple") +
  geom_smooth(method = "lm", se = FALSE, colour = "orange")


## ---- move-y1-coef
coefs <- 2:5 %>%
  map(~ rq(df[, .] ~ x, data = df, seq(0.1, 0.9, 0.1))) %>%
  map_df(~ as.data.frame(t(as.matrix(coef(.)))))
colnames(coefs) <- c("intercept", "slope")
tau <- rep(seq(0.1, 0.9, by = 0.1), 4)
model <- paste('rq', rep(1:4, each = 9), sep="")

df_m1 <- data.frame(model, tau, coefs)
df_mf <- df_m1 %>% gather(variable, value, -c(model, tau))
ggplot(df_mf, aes(x = tau, y = value, colour = model)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ variable, scale = "free_y") +
  xlab('quantiles') +
  ylab('coefficients')

## ---- move-y-multi1
n <- 100
set.seed(101)
x1 <- sort(rnorm(n, 0, 1))
x2 <- sort(rnorm(n, 1, 2))
y <- 40*(x1 + x2) + x1*rnorm(100, 0, 10) + x2*rnorm(100, 0, 10)
selectedX <- sample(50:100,5)
y2<- y
y2[selectedX] <- x1[1:5]*rnorm(5, 0, 10) + x2[1:5]*rnorm(5, 0, 10)
y3 <- y2
y3[selectedX] <- y2[selectedX] - 100
y4 <- y3
y4[selectedX] <- y3[selectedX] - 100
df <- data.frame(y, y2, y3, y4, x1, x2)
coefs <- 1:4 %>%
  map(~ rq(df[, .] ~ x1 + x2, data = df, seq(0.1, 0.9, 0.1))) %>%
  map_df(~ as.data.frame(t(as.matrix(coef(.)))))
colnames(coefs) <- c("intercept", "slope_x1", "slope_x2")
tau <- rep(seq(0.1, 0.9, by = 0.1), 4)
model <- paste('rq', rep(1:4, each = 9), sep="")
df_m1 <- data.frame(model, tau, coefs)
df_mf <- df_m1 %>% gather(variable, value, -c(model, tau))
ggplot(df_mf, aes(x = tau, y = value, colour = model)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ variable, scale = "free_y") +
  xlab('quantiles') +
  ylab('coefficients')
## ---- move-x1
x <- sort(runif(100))
y <- 40*x + x*rnorm(100, 0, 10)
selectedIdx <- sample(50:100,5)
df <- data.frame(y)
df$y2 <- y
df$x <- x
df$y2[selectedIdx] <- df$x[1:5]*rnorm(5, 0, 10)
df$x2 <- x
df$x2[selectedIdx] <- df$x2[selectedIdx] + 0.2
df$x3 <- df$x2
df$x3[selectedIdx] <- df$x3[selectedIdx] + 0.2
df$x4 <- df$x3
df$x4[selectedIdx] <- df$x4[selectedIdx] + 0.2
df_m <- df %>% gather(variable, value, -y, -y2)
ggplot(df_m, aes(x = value, y=y2)) +
  geom_point() +
  xlab("x") +
  ylab("y") +
  facet_wrap(~variable, ncol=2, scale = "free") +
  geom_quantile(quantiles = seq(0.1, 0.9, 0.1))

## ---- move-x1-coef
coefs <- 3:6 %>%
  map(~ rq(df$y2 ~ df[, .], data = df, seq(0.1, 0.9, 0.1))) %>%
  map_df(~ as.data.frame(t(as.matrix(coef(.)))))
colnames(coefs) <- c("intercept", "slope")
tau <- rep(seq(0.1, 0.9, by = 0.1), 4)
model <- paste('rq', rep(1:4, each = 9), sep="")
df_m1 <- data.frame(model, tau, coefs)
df_mf <- df_m1 %>% gather(variable, value, -c(model, tau))
ggplot(df_mf, aes(x = tau, y = value, colour = model)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ variable, scale = "free_y") +
  xlab('quantiles') +
  ylab('coefficients')

## ---- outlier-number1
x <- sort(runif(100))
y <- 40*x + x*rnorm(100, 0, 10)
selectedX1 <- sample(50:100, 5)
y_number_y1 <- y
y_number_y1[selectedX1] <- x[1:5]*rnorm(5, 0, 10)
selectedX2 <- sample(50:100, 10)
y_number_y2 <- y
y_number_y2[selectedX2] <- x[1:10]*rnorm(10, 0, 10)
selectedX3 <- sample(50:100, 15)
y_number_y3 <- y
y_number_y3[selectedX3] <- x[1:15]*rnorm(15, 0, 10)
df <- data.frame(x, y, y_number_y1, y_number_y2, y_number_y3)
df_m <- df %>% gather(variable, value, -x)
ggplot(df_m, aes(x=x, y=value)) +
  geom_point() +
  xlab("x") +
  ylab("y") +
  facet_wrap(~variable, ncol=2) +
  geom_quantile(quantiles = seq(0.1, 0.9, 0.1))

## ---- real-data1-lm
data(ais)
ais_female <- subset(ais, Sex == 1)
ais_female_o <- ais_female[-75, ]
coef1 <- lm(BMI ~ LBM, data = ais_female)$coef
coef2 <- lm(BMI ~ LBM, data = ais_female_o)$coef
coefs <- c(coef1[2], coef2[2])
inters <- c(coef1[1], coef2[1])
flag <- c("with-outlier", "without-outlier")
coef_o <- data.frame(coefs, inters, flag)
ggplot(ais_female, aes(x = LBM, y = BMI)) +
  geom_point(alpha = 0.1) +
  geom_abline(data = coef_o, aes(intercept = inters, slope = coefs,
                                 colour = flag))


## ---- real-data1-rq
coef1 <- rq(BMI ~ LBM, tau = c(0.1, 0.5, 0.9), data = ais_female,
            method = "br")$coef
rq_coef1 <- data.frame(intercept = coef1[1, ], coef = coef1[2, ],
                       tau_flag = colnames(coef1))
coef2 <- rq(BMI ~ LBM, tau = c(0.1, 0.5, 0.9), data = ais_female_o,
            method = "br")$coef
rq_coef2 <- data.frame(intercept = coef2[1, ], coef = coef2[2, ],
                       tau_flag = colnames(coef2))
ggplot(ais_female) +
  geom_point(aes(x = LBM, y = BMI), alpha = 0.1) +
  geom_abline(data = rq_coef1, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))+
  geom_abline(data = rq_coef2, aes(intercept = intercept,
                                   slope = coef, colour = tau_flag))

## ---- simplex-method1
data(ais)
tau <- c(0.1, 0.5, 0.9)
ais_female <- subset(ais, Sex == 1)
br <- rq(BMI ~ LBM, tau = tau, data = ais_female, method = 'br')
coef <- br$coef
br_result <- frame_br(br, tau)
origin_obs <- br_result$all_observation
use_obs <- br_result$fitting_point
ggplot(origin_obs,
    aes(x = value, y = y)) +
    geom_point(alpha = 0.1) +
    geom_abline(slope = coef[2, 1], intercept = coef[1,1],
                colour = "gray") +
    geom_abline(slope = coef[2, 2], intercept = coef[1,2],
                colour = "gray") +
    geom_abline(slope = coef[2, 3], intercept = coef[1,3],
                colour = "grey") +
    ylab('y') +
    xlab('x') +
    facet_wrap(~variable, scales = "free_x", ncol = 2) +
    geom_point(data = use_obs, aes(x = value, y = y,
                                        group = tau_flag,
                                        colour = tau_flag,
                                        shape = obs))

## ---- simplex-method1-multi

br <- rq(BMI ~ LBM + Bfat , tau = tau, data = ais_female, method = 'br')
tau <- c(0.1, 0.5, 0.9)
br_result <- frame_br(br, tau)
origin_obs <- br_result$all_observation
use_obs <- br_result$fitting_point
ggplot(origin_obs,
       aes(x = value, y = y)) +
  geom_point(alpha = 0.1) +
  ylab('y') +
  xlab('x') +
  facet_wrap(~variable, scales = "free_x", ncol = 2) +
  geom_point(data = use_obs, aes(x = value, y = y,
                                 group = tau_flag,
                                 colour = tau_flag,
                                 shape = obs))


## ---- fn-method1
tau <- c(0.1, 0.5, 0.9)
fn <- rq(BMI ~ LBM, data = ais_female, tau = tau, method = 'fn')
fn_obs <- frame_fn_obs(fn, tau)
head(fn_obs)

fn1 <- fn_obs[,1]
case <- 1: length(fn1)
fn1 <- cbind(case, fn1)
m <- data.frame(y = ais_female$BMI, x1 = ais_female$LBM,fn1)
p <- length(attr(fn$coefficients, "dimnames")[[1]])
m_f <- m %>% gather(variable, value, -case, -fn1, -y)
mf_a <- m_f %>%
  group_by(variable) %>%
  arrange(variable, desc(fn1)) %>%
  filter(row_number() %in% 1:p)
p1 <- ggplot(m_f, aes(x = value, y = y)) +
 geom_point(alpha = 0.1) +
  geom_point(data = mf_a, size = 3, colour = "purple") +
  facet_wrap(~variable, scale = "free_x") +
  xlab("x")
 fn2 <- fn_obs[,2]
 case <- 1: length(fn2)
 fn2 <- cbind(case, fn2)
 m <- data.frame(y = ais_female$BMI, x1 = ais_female$LBM,
                  fn2)
 p <- length(attr(fn$coefficients, "dimnames")[[1]])
 m_f <- m %>% gather(variable, value, -case, -fn2, -y)
 mf_a <- m_f %>%
    group_by(variable) %>%
    arrange(variable, desc(fn2)) %>%
    filter(row_number() %in% 1:p )
 p2 <- ggplot(m_f, aes(x = value, y = y)) +
    geom_point(alpha = 0.1) +
    geom_point(data = mf_a, size = 3, colour = "blue", alpha = 0.5) +
    facet_wrap(~variable, scale = "free_x") +
    xlab("x")
 fn3 <- fn_obs[ ,3]
 case <- 1: length(fn3)
 fn3 <- cbind(case, fn3)
 m <- data.frame(y = ais_female$BMI, x1 = ais_female$LBM,
                  fn3)
 p <- length(attr(fn$coefficients, "dimnames")[[1]])
 m_f <- m %>% gather(variable, value, -case, -fn3, -y)
 mf_a <- m_f %>%
   group_by(variable) %>%
   arrange(variable, desc(fn3)) %>%
   filter(row_number() %in% 1:p )
 p3 <- ggplot(m_f, aes(x = value, y = y)) +
   geom_point(alpha = 0.1) +
   geom_point(data = mf_a, size = 3, colour = "orange") +
   facet_wrap(~variable, scale = "free_x") +
   xlab("x")
 grid.arrange(p1, p2, p3, ncol = 3)

## --- fn-weights1
 tau <- c(0.1, 0.5, 0.9)
 fn <- rq(BMI ~ LBM, data = ais_female, tau = tau, method = 'fn')
 fn_obs <- frame_fn_obs(fn, tau)
 p <- 2
 obs <- data.frame(cbind(fn_obs,id = 1:nrow(fn_obs)))
 selected <- NULL
 for(i in 1:3){
   data <- obs[order(obs[,i],decreasing = T),c(i,4)][1:p,]
   data <- cbind(data,idx=1:p)
   colnames(data) <- c("value","id","idx")
   data = cbind(data,type=rep(colnames(obs)[i],p))
   if(is.null(selected)){
     selected = data
   }else{
     selected =  rbind(selected,data)
   }
 }
 selected$value = round(selected$value,3)
 ggplot(selected,aes(x=idx,y=value,colour=type))+
   geom_point(aes(size=value),alpha=0.5)+
   geom_text(aes(label = id), hjust = 0, vjust= 0)+
   facet_wrap( ~ type,scale="free_y")

## ---- frame-nlrq1
x <- rep(1:25, 20)
y <- SSlogis(x, 10, 12, 2) * rnorm(500, 1, 0.1)
Dat <- data.frame(x = x, y = y)
formula <- y ~ SSlogis(x, Aysm, mid, scal)
nlrq_m <- frame_nlrq(formula, data = Dat, tau = c(0.1, 0.5, 0.9))
weights <- nlrq_m$weights
m <- data.frame(Dat, weights)
m_f <- m %>% gather(tau_flag, value, -x, -y)
ggplot(m_f, aes(x = x, y = y, colour = tau_flag)) +
  geom_point(aes(size = value), alpha = 0.5) +
  facet_wrap(~tau_flag)

## ---- ALD1
x <- matrix(ais_female$LBM, ncol = 1)
y <- ais_female$BMI
tau = c(0.1, 0.5, 0.9)
ald_data <- frame_ald(y, x, tau, smooth = 10, error = 1e-6,
                   iter = 2000)
ggplot(ald_data) +
    geom_line(aes(x = r, y = d, group = obs, colour = tau_flag)) +
    facet_wrap(~tau_flag, ncol = 1,scales = "free_y") +
    xlab('') +
    ylab('Asymmetric Laplace Distribution Density Function')

## ---- Residual-Robust1
ais_female <- subset(ais, Sex == 1)
tau <- c(0.1, 0.5, 0.9)
object <- rq(BMI ~ LBM + Bfat, data = ais_female, tau = tau)
plot_distance <- frame_distance(object, tau = c(0.1, 0.5, 0.9))
distance <- plot_distance[[1]]
head(distance)
cutoff_v <- plot_distance[[2]]
cutoff_v
cutoff_h <- plot_distance[[3]]
cutoff_h
n <- nrow(object$model)
case <- rep(1:n, length(tau))
distance <- cbind(case, distance)
distance$residuals <- abs(distance$residuals)
distance1 <- distance %>% filter(tau_flag == 'tau0.1')
p1 <- ggplot(distance1, aes(x = rd, y = residuals)) +
 geom_point() +
 geom_hline(yintercept = cutoff_h[1], colour = "red") +
 geom_vline(xintercept = cutoff_v, colour = "red") +
 geom_text(data = subset(distance1, residuals > cutoff_h[1]|
                           rd > cutoff_v),
           aes(label = case), hjust = 0, vjust = 0) +
 xlab("Robust Distance") +
 ylab("|Residuals|")

distance2 <- distance %>% filter(tau_flag == 'tau0.5')
p2 <- ggplot(distance1, aes(x = rd, y = residuals)) +
 geom_point() +
 geom_hline(yintercept = cutoff_h[2], colour = "red") +
 geom_vline(xintercept = cutoff_v, colour = "red") +
 geom_text(data = subset(distance1, residuals > cutoff_h[2]|
                           rd > cutoff_v),
           aes(label = case), hjust = 0, vjust = 0) +
 xlab("Robust Distance") +
 ylab("|Residuals|")

distance3 <- distance %>% filter(tau_flag == 'tau0.9')
p3 <- ggplot(distance1, aes(x = rd, y = residuals)) +
 geom_point() +
 geom_hline(yintercept = cutoff_h[3], colour = "red") +
 geom_vline(xintercept = cutoff_v, colour = "red") +
 geom_text(data = subset(distance1, residuals > cutoff_h[3]|
             rd > cutoff_v),
         aes(label = case), hjust = 0, vjust = 0) +
xlab("Robust Distance") +
 ylab("|Residuals|")

grid.arrange(p1, p2, p3, ncol = 3)


## ----GCD1
ais_female <- subset(ais, Sex == 1)
y <- ais_female$BMI
x <- cbind(1, ais_female$LBM, ais_female$Bfat)
tau <- c(0.1, 0.5, 0.9)
case <- rep(1:length(y), length(tau))
GCD <- frame_mle(y, x, tau, error = 1e-06, iter = 10000,
                  method = 'cook.distance')
GCD_m <- cbind(case, GCD)
ggplot(GCD_m, aes(x = case, y = value )) +
    geom_point() +
    facet_wrap(~variable, scale = 'free_y') +
    geom_text(data = subset(GCD_m, value > mean(value) + 2*sd(value)),
              aes(label = case), hjust = 0, vjust = 0) +
    xlab("case number") +
    ylab("Generalized Cook Distance")

## ---- QD1
QD <- frame_mle(y, x, tau, error = 1e-06, iter = 100,
               method = 'qfunction')
QD_m <- cbind(case, QD)
ggplot(QD_m, aes(x = case, y = value)) +
 geom_point() +
 facet_wrap(~variable, scale = 'free_y')+
 geom_text(data = subset(QD_m, value > mean(value) + sd(value)),
           aes(label = case), hjust = 0, vjust = 0) +
 xlab('case number') +
 ylab('Qfunction Distance')


## ---- BP1
ais_female <- subset(ais, Sex == 1)
y <- ais_female$BMI
x <- matrix(c(ais_female$LBM, ais_female$Bfat), ncol = 2, byrow = FALSE)
tau <- c(0.1, 0.5, 0.9)
case <- rep(1:length(y), length(tau))
prob <- frame_bayes(y, x, tau, M =  500, burn = 100,
                 method = 'bayes.prob')

prob_m <- cbind(case, prob)
ggplot(prob_m, aes(x = case, y = value )) +
   geom_point() +
   facet_wrap(~variable, scale = 'free') +
  geom_text(data = subset(prob_m, value > mean(value) + 2*sd(value)),
            aes(label = case), hjust = 0, vjust = 0) +
   xlab("case number") +
   ylab("Mean probability of posterior distribution")

## ---- BKL1
kl <- frame_bayes(y, x, tau, M =  5, burn = 1,
                  method = 'bayes.kl')
kl_m <- cbind(case, kl)
ggplot(kl_m, aes(x = case, y = value)) +
  geom_point() +
  facet_wrap(~variable, scale = 'free')+
  geom_text(data = subset(kl_m, value > mean(value) + 2*sd(value)),
            aes(label = case), hjust = 0, vjust = 0) +
  xlab('case number') +
  ylab('Kullback-Leibler')



