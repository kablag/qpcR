\name{ratiobatch}
\alias{ratiobatch}

\title{Calculation of ratios in a batch format for multiple genes/samples}

\description{For multiple qPCR data from type 'pcrbatch', this function calculates ratios between samples, using normalization against one or more reference gene(s), if supplied. Multiple reference genes can be averaged according to Vandesompele \emph{et al}. (2002). The input may be single qPCR data or (more likely) data containing replicates. This is essentially a version of \code{\link{ratiocalc}} that can handle multiple reference genes and genes-of-interest with multiple (replicated) samples as found in large-scale qPCR runs such as 96- or 384-Well plates. A boxplot representation for all Monte-Carlo simulations, permutations and error propagations including 95\% confidence intervals is calculated for each ratio calculation.
}

\usage{
ratiobatch(data, group = NULL, plot = TRUE, 
           combs = c("same", "across", "all"), 
           type.eff = "mean.single", which.cp = "cpD2", 
           which.eff = "sli", refmean = FALSE,
           dataout = NULL, verbose = TRUE, ...)
}

\arguments{
  \item{data}{multiple qPCR data generated by \code{\link{pcrbatch}}.}
  \item{group}{a character vector defining the replicates (if any) of control/treatment samples and reference genes/genes-of-interest. See 'Details'}.
  \item{plot}{logical. If \code{TRUE}, plots are displayed for the diagnostics and analysis.}
  \item{combs}{type of combinations between different samples (i.e. r1s1:g1s2). See 'Details'.}
  \item{type.eff}{type of efficiency averaging used. Same as in \code{\link{ratiocalc}}.}
  \item{which.eff}{efficiency obtained from which method. Same as in \code{\link{ratiocalc}}.}
  \item{which.cp}{threshold cycle obtained from which method. Same as in \code{\link{ratiocalc}}.}   
  \item{dataout}{an optional file path where to store the result dataframe.}   
  \item{refmean}{logical. If \code{TRUE}, multiple reference are averaged before calculating the ratios. See 'Details'.}
  \item{verbose}{logical. If \code{TRUE}, the steps of analysis are shown in the console window}
  \item{...}{other parameters to be passed to \code{\link{ratiocalc}}.}
}

\details{
Similar to \code{\link{ratiocalc}}, the replicates of the 'pcrbatch' data columns are to be defined as a character vector with the following abbreviations:

"g1s1":   gene-of-interest #1 in treatment sample #1\cr
"g1c1":   gene-of-interest #1 in control sample #1\cr
"r1s1":   reference gene #1 in treatment sample #1\cr
"r1c1":   reference gene #1 in control sample #1

There is no distinction between the different technical replicates so that three different runs of gene-of-interest #1 in treatment sample #2 are defined as c("g1s2", "g1s2", "g1s2"). 

Example:\cr
1 control sample with 2 genes-of-interest (2 technical replicates), 2 treatment samples with 2 genes-of-interest (2 technical replicates):\cr
"g1c1", "g1c1", "g2c1", "g2c1", "g1s1", "g1s1", "g1s2", "g1s2", "g2s1", "g2s1", "g2s2", "g2s2"

The ratios are calculated for all pairwise 'rc:gc' and 'rs:gs' combinations according to:\cr
For all control samples \eqn{i = 1 \ldots I} and treatment samples \eqn{j = 1 \ldots J}, reference genes \eqn{k = 1 \ldots K} and genes-of-interest \eqn{l = 1 \ldots L}, calculate\cr

Without reference genes:  \deqn{\frac{E(g_lc_i)^{cp(g_lc_i)}}{E(g_ls_j)^{cp(g_ls_j)}}}
With reference genes: \deqn{\frac{E(g_lc_i)^{cp(g_lc_i)}}{E(g_ls_j)^{cp(g_ls_j)}}/\frac{E(r_kc_i)^{cp(r_kc_i)}}{E(r_ks_j)^{cp(r_ks_j)}}}
For the mechanistic models \code{makX/cm3} the following is calculated:\cr

Without reference genes: \deqn{\frac{D_0(g_ls_j)}{D_0(g_lc_i)}} 
With reference genes: \deqn{\frac{D_0(g_ls_j)}{D_0(g_lc_i)}/\frac{D_0(r_ks_j)}{D_0(r_kc_i)}}

Efficiencies can be taken from the individual curves or averaged from the replicates as described in the documentation to \code{\link{ratiocalc}}. It is also possible to give external efficiencies (i.e. acquired by some calibration curve) to the function. See 'Examples'. The different combinations of \code{type.eff}, \code{which.eff} and \code{which.cp} can yield very different results in ratio calculation. We observed a relatively stable setup which minimizes the overall variance using the combination
  
\code{type.eff = "mean.single"}     # averaging efficiency across replicates\cr
\code{which.eff = "sli"}            # taking efficiency from the sliding window method\cr
\code{which.cp = "sig"}             # using the second derivative maximum of a sigmoidal fit 

This is also the default setup in the function. The lowest variance can be obtained for the threshold cycles if the asymmetric 5-parameter \code{l5} model is used in the \code{\link{pcrbatch}} function. 

There are three different combination setups possible when calculating the pairwise ratios:\cr
\code{combs = "same"}: reference genes, genes-of-interest, control and treatment samples are the \code{same}, i.e. \eqn{i = k, m = o, j = n, l = p}.\cr
\code{combs = "across"}: control and treatment samples are the same, while the genes are combinated, i.e. \eqn{i \neq k, m \neq o, j = n, l = p, }.\cr
\code{combs = "all"}: reference genes, genes-of-interest, control and treatment samples are all combinated, i.e. \eqn{i \neq k, m \neq o, j \neq n, l \neq p}.

The last setting rarely makes sense and is very time-intensive. \code{combs = "same"} is the most common setting, but \code{combs = "across"} also makes sense if different genes-of-interest and reference gene combinations should be calculated for the same samples.

From version 1.3-6, \code{ratiobatch} has the option of averaging several reference genes, as described in Vandesompele \emph{et al.} (2002). Threshold cycles and efficiency values for any \eqn{i} reference genes with \eqn{j} replicates are averaged before calculating the ratios using the averaged value \eqn{\mu_r} for all reference genes in a control/treatment sample. The overall error \eqn{\sigma_r} is obtained by error propagation. The whole procedure is accomplished by function \code{\link{refmean}}, which can be used as a stand-alone function, but is most conveniently used inside \code{ratiobatch} setting \code{refmean = TRUE}. See in 'Examples'. For details about reference gene averaging by \code{\link{refmean}}, see there. If none or only one per sample is found, the data is analyzed without using reference gene averaging/error propagation.
}

\value{
A list with the following components:
\item{resList}{a list with the results from the combinations as list items.}
\item{resDat}{a dataframe with the results in colums.}
Both \code{resList} and \code{resDat} have as names the combinations used for the ratio calculation.
If \code{plot = TRUE}, a boxplot matrix from the Monte-Carlo simulations, permutations and error propagations is given including 95\% confidence intervals as coloured horizontal lines.
}

\author{
Andrej-Nikolai Spiess
}

\note{
This function can be used quite conveniently when the raw fluorescence data from the 96- or 384-well runs come from Excel with 'Cycles' in the first column and run descriptions as explained above in the remaining column descriptions (such as 'r1c6'). Examples for a proper format can be found under \url{http://www.dr-spiess.de//qpcR//datasets.html}. This data may then be imported into \R by \code{dat <- pcrimport()}.
}

\references{
Accurate normalization of real-time quantitative RT-PCR data by geometric averaging of multiple internal control genes.\cr
Vandesompele J, De Preter K, Pattyn F, Poppe B, Van Roy N, De Paepe A, Speleman F.\cr
\emph{Genome Biol} (2002), \bold{3}: research0034-research0034.11.\cr
}

\examples{
\dontrun{
## One reference gene, one gene of interest,
## one control and one treatment sample with 
## 4 replicates each => 1 x Ratio = 1.
DAT1 <- pcrbatch(reps, fluo = c(2:9, 2:9), model = l5)
GROUP1 <- c("g1c1", "g1c1", "g1c1", "g1c1",
            "g1s1", "g1s1", "g1s1", "g1s1", 
            "r1c1", "r1c1", "r1c1", "r1c1",
            "r1s1", "r1s1", "r1s1", "r1s1") 
ratiobatch(DAT1, GROUP1, refmean = FALSE)  

## One reference gene, one gene of interest,
## two control and two treatment samples with 
## 2 replicates each => 4 x Ratio = 1.
DAT2 <- pcrbatch(reps, fluo = c(2:9, 2:9), model = l5)
GROUP2 <- c("g1c1", "g1c1", "g1c2", "g1c2",
            "g1s1", "g1s1", "g1s2", "g1s2", 
            "r1c1", "r1c1", "r1c2", "r1c2",
            "r1s1", "r1s1", "r1s2", "r1s2") 
ratiobatch(DAT2, GROUP2, refmean = FALSE)

## Two reference genes, one gene of interest,
## one control and one treatment samples with 
## 4 replicates each => 2 x Ratio = 1.
DAT3 <- pcrbatch(reps, fluo = c(2:9, 2:9, 2:9), model = l5)
GROUP3 <- c("g1c1", "g1c1", "g1c1", "g1c1",
            "g1s1", "g1s1", "g1s1", "g1s1", 
            "r1c1", "r1c1", "r1c1", "r1c1",
            "r1s1", "r1s1", "r1s1", "r1s1",
            "r2c1", "r2c1", "r2c1", "r2c1",
            "r2s1", "r2s1", "r2s1", "r2s1") 
ratiobatch(DAT3, GROUP3, refmean = FALSE)

## Two reference genes, one gene of interest,
## one control and one treatment samples with 
## 4 replicates each.
## Reference genes are averaged => 1 x Ratio = 1.
DAT4 <- pcrbatch(reps, fluo = c(2:9, 2:9, 2:9), model = l5)
GROUP4 <- c("g1c1", "g1c1", "g1c1", "g1c1",
            "g1s1", "g1s1", "g1s1", "g1s1", 
            "r1c1", "r1c1", "r1c1", "r1c1",
            "r1s1", "r1s1", "r1s1", "r1s1",
            "r2c1", "r2c1", "r2c1", "r2c1",
            "r2s1", "r2s1", "r2s1", "r2s1") 
ratiobatch(DAT4, GROUP4, refmean = TRUE)

## Same as above, but use same efficiency E = 2.         
ratiobatch(DAT4, GROUP4, which.eff = 2) 
                   
## No reference genes, two genes-of-interest, 
## two control and two treatment samples with
## 2 replicates each, efficiency from sigmoidal model. 
DAT6 <- pcrbatch(reps, fluo = 2:17, model = l5)
GROUP6 <- c("g1s1", "g1s1", "g1s2", "g1s2",
            "g2s1", "g2s1", "g2s2", "g2s2",
            "g1c1", "g1c1", "g1c2", "g1c2",
            "g2c1", "g2c1", "g2c2", "g2c2")            
ratiobatch(DAT6, GROUP6, which.eff = "sig")

## Same as above, but using a mechanistic model (mak3).
## BEWARE: type.eff must be "individual"!
DAT7 <- pcrbatch(reps, fluo = 2:17, model = l5,
                 methods = c("sigfit", "mak3"))
GROUP7 <- c("g1s1", "g1s1", "g1s2", "g1s2",
            "g2s1", "g2s1", "g2s2", "g2s2",
            "g1c1", "g1c1", "g1c2", "g1c2",
            "g2c1", "g2c1", "g2c2", "g2c2")
ratiobatch(DAT7, GROUP7, which.eff = "mak", 
           type.eff = "individual")

## Using external efficiencies from a 
## calibration curve. Can be supplied by the
## user from external calibration (or likewise),
## but in this example acquired by function 'calib'.
ml1 <- modlist(reps, fluo = 2:25, model = l5)
DIL <- rep(10^(5:0), each = 4) 
EFF <- calib(refcurve = ml1, dil = DIL)$eff   
DAT8 <- pcrbatch(ml1)
GROUP8 <- c(rep("g1s1", 4), rep("g1s2", 4),
            rep("g1s3", 4), rep("g1s4", 4), 
            rep("g1s5", 4), rep("g1c1", 4)) 
ratiobatch(DAT8, GROUP8, which.eff = EFF)
}
}



\keyword{nonlinear}

