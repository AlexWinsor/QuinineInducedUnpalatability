# create panelled figure for attack likelihood

rm(list = ls(all = TRUE))


library(here) # to get path of the Rproj root
library(ggplot2) # to plot
require(gridExtra) # for function gridarrange
library(arm)
library(pbapply)


FocalAttacks1 <- read.csv(file="3_ExtractedData/FocalAttacks/FocalAttacks1.csv", header=TRUE, sep=",")
FocalAttacks15 <- read.csv(file="3_ExtractedData/FocalAttacks/FocalAttacks15.csv", header=TRUE, sep=",")
FocalAttacks2 <- read.csv(file="3_ExtractedData/FocalAttacks/FocalAttacks2.csv", header=TRUE, sep=",")
FocalAttacks3 <- read.csv(file="3_ExtractedData/FocalAttacks/FocalAttacks3.csv", header=TRUE, sep=",")
FocalAttacks3F <- read.csv(file="3_ExtractedData/FocalAttacks/FocalAttacks3F.csv", header=TRUE, sep=",")


PrepDF <- function(df){

  mod1 <- glm (FocalAttackedYN ~ -1+ FocalPalatabilityTreatment + scale(FocalColorCode)
               , family = 'binomial', data = df)
  summary(mod1)
  
  effects_table <- as.data.frame(cbind(est=invlogit(summary(mod1)$coeff[,1]),
                                       CIhigh=invlogit(summary(mod1)$coeff[,1]+summary(mod1)$coeff[,2]*1.96),
                                       CIlow=invlogit(summary(mod1)$coeff[,1]-summary(mod1)$coeff[,2]*1.96)))
  effects_table <- effects_table[-nrow(effects_table),]
  effects_table$Palatability <- c("Control","DB")
  
  return(effects_table)
}

effects_table15 <- PrepDF(FocalAttacks15)
effects_table2 <- PrepDF(FocalAttacks2)
effects_table3 <- PrepDF(FocalAttacks3)

{plot1_5_lkh <- 
    
    ggplot(data=effects_table15, aes(x=Palatability, y=est)) + 
    scale_y_continuous(name="Prey probability of being attacked first", 
                       limits=c(0, 1), breaks =c(0,0.25,0.50,0.75,1), labels=scales::percent)+ # 0.75 converted to 75%
    theme_classic() + # white backgroun, x and y axis (no box)
    labs(title = "DB solution concentration: 1.5%") +
    
    geom_errorbar(aes(ymin=CIlow, ymax=CIhigh), width =0.4)+ # don't plot bor bars on x axis tick, but separate them (dodge)
    geom_point(size =4, stroke = 1) +
    geom_hline(yintercept=0.5, linetype="dashed", color = "grey48") +
        theme(panel.border = element_rect(colour = "black", fill=NA), # ad square box around graph 
          axis.title.x=element_text(size=10),
          axis.title.y=element_text(size=10),
          plot.title = element_text(hjust = 0.5, size = 10))
}

{plot2_lkh <- 
    
    ggplot(data=effects_table2, aes(x=Palatability, y=est)) + 
    scale_y_continuous(limits=c(0, 1), breaks =c(0,0.25,0.50,0.75,1))+ 
    theme_classic() + # white backgroun, x and y axis (no box)
    labs(title = "DB solution concentration: 2%") +
    
    geom_errorbar(aes(ymin=CIlow, ymax=CIhigh), width =0.4)+ # don't plot bor bars on x axis tick, but separate them (dodge)
    geom_point(size =4, stroke = 1) +
    geom_hline(yintercept=0.5, linetype="dashed", color = "grey48") +
    theme(panel.border = element_rect(colour = "black", fill=NA), # ad square box around graph 
          axis.title.x=element_text(size=10),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          plot.title = element_text(hjust = 0.5, size = 10))
}

{plot3_lkh <- 
    
    ggplot(data=effects_table3, aes(x=Palatability, y=est)) + 
    scale_y_continuous(limits=c(0, 1), breaks =c(0,0.25,0.50,0.75,1))+ 
    theme_classic() + # white backgroun, x and y axis (no box)
    labs(title = "DB solution concentration: 3%") +
    
    geom_errorbar(aes(ymin=CIlow, ymax=CIhigh), width =0.4)+ # don't plot bor bars on x axis tick, but separate them (dodge)
    geom_point(size =4, stroke = 1) +
    geom_hline(yintercept=0.5, linetype="dashed", color = "grey48") +
    theme(panel.border = element_rect(colour = "black", fill=NA), # ad square box around graph 
          axis.title.x=element_text(size=10),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          plot.title = element_text(hjust = 0.5, size = 10))
}


plot1_5_lkh_g <- ggplotGrob(plot1_5_lkh)
plot2_lkh_g <- ggplotGrob(plot2_lkh)
plot3_lkh_g <- ggplotGrob(plot3_lkh)

setEPS() 
pdf("5_Figures/AttackLikelihood/Fig1A_AllFirstAttacks.pdf", height=5, width=6.85)
grid.arrange(cbind(plot1_5_lkh_g,plot2_lkh_g, plot3_lkh_g, size="last"))
dev.off()




PrepDF_withtraining <- function(df){

mod1 <- glm (FocalAttackedYN ~ -1+PalatExpo + scale(FocalColorCode), family = 'binomial', data = df)
summary(mod1)

effects_table <- as.data.frame(cbind(est=invlogit(summary(mod1)$coeff[,1]),
                                      CIhigh=invlogit(summary(mod1)$coeff[,1]+summary(mod1)$coeff[,2]*1.96),
                                      CIlow=invlogit(summary(mod1)$coeff[,1]-summary(mod1)$coeff[,2]*1.96)))
effects_table <- effects_table[-nrow(effects_table),]
effects_table$PriorExposure <- c("Naive", "Trained", "Naive","Trained")
effects_table$Palatability <- c("Control", "Control", "DB","DB")

return(effects_table)
}

effects_table1 <- PrepDF_withtraining(FocalAttacks1)
effects_table3F <- PrepDF_withtraining(FocalAttacks3F)

{plot1_lkh <- 
  
  ggplot(data=effects_table1, aes(x=Palatability, y=est,colour=PriorExposure, shape = PriorExposure)) + 
  scale_y_continuous(name="Prey probability of being attacked first", 
                     limits=c(0, 1), breaks =c(0,0.25,0.50,0.75,1), labels=scales::percent)+ # 0.75 converted to 75%
  theme_classic() + # white backgroun, x and y axis (no box)
  labs(title = "DB solution concentration: 1%") +
  
  geom_errorbar(aes(ymin=CIlow, ymax=CIhigh, col=PriorExposure), width =0.4,na.rm=TRUE, position = position_dodge(width=0.5))+ # don't plot bor bars on x axis tick, but separate them (dodge)
    geom_hline(yintercept=0.5, linetype="dashed", color = "grey48") +
    geom_point(size =4, aes(shape=PriorExposure, col=PriorExposure), stroke = 1, position = position_dodge(width=0.5)) +
  scale_colour_manual(name= "Prior exposure to DB", values=c("Black","Grey")) +
  scale_shape_manual(name= "Prior exposure to DB", values=c(16,17))+ # duplicate title to combine legend
  theme(panel.border = element_rect(colour = "black", fill=NA), # ad square box around graph 
        legend.position=c(0.5,0.85),
        legend.title = element_text(size=rel(0.8)),
        legend.text = element_text(size=rel(0.7)),
        legend.key.size = unit(0.8, 'lines'),
        axis.title.x=element_text(size=10),
        axis.title.y=element_text(size=10),
        plot.title = element_text(hjust = 0.5, size = 10)) +
  guides(shape = guide_legend(override.aes = list(linetype = 0, size = 2))) # remove bar o top of symbol in legend

  }

{plot3F_lkh <- 
  
  ggplot(data=effects_table3F, aes(x=Palatability, y=est,colour=PriorExposure, shape = PriorExposure)) + 
  scale_y_continuous(limits=c(0, 1), breaks =c(0,0.25,0.50,0.75,1))+ 
  theme_classic() + # white backgroun, x and y axis (no box)
  labs(title = "DB solution concentration: 3%") +
  geom_errorbar(aes(ymin=CIlow, ymax=CIhigh, col=PriorExposure),  width =0.4,na.rm=TRUE, position = position_dodge(width=0.5))+ # don't plot bor bars on x axis tick, but separate them (dodge)
    geom_hline(yintercept=0.5, linetype="dashed", color = "grey48") +
    geom_point(size =4, aes(shape=PriorExposure, col=PriorExposure), stroke = 1, position = position_dodge(width=0.5)) +
  scale_colour_manual(values=c("Black","Grey")) +
  scale_shape_manual(values=c(16,17))+ # duplicate title to combine legend
  theme(panel.border = element_rect(colour = "black", fill=NA), # ad square box around graph 
        legend.position="none",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.title.x=element_text(size=10),
        plot.title = element_text(hjust = 0.5, size=10))

}

plot1_lkh_g <- ggplotGrob(plot1_lkh)
plot3F_lkh_g <- ggplotGrob(plot3F_lkh)

setEPS() 
pdf("5_Figures/AttackLikelihood/Fig1B_AllFirstAttacks.pdf", height=5, width=5)
grid.arrange(cbind(plot1_lkh_g,plot3F_lkh_g, size="last"))
dev.off()

