"""
Mini Fazenda - Demo (homenagem de fa)
=====================================

Protótipo ORIGINAL, feito do zero, inspirado nas mecânicas e no visual
isométrico do clássico "Mini Fazenda" da Vostu (Orkut/Facebook, ~2009-2016).

Todos os sprites deste arquivo (tiles, casa, plantações, cerca, galinha,
moedas) foram desenhados do zero com código (Pillow), NÃO são assets da
Vostu nem de nenhum outro jogo - e vêm embutidos em base64 aqui dentro,
então esse único arquivo .py já é o jogo completo (não precisa baixar
mais nada além dele).

Como rodar:
    pip install pygame-ce      (ou "pip install pygame" se sua versão do
                                 Python já tiver wheel pronto pra ela)
    python mini_fazenda_demo.py

Controles:
    - Clique num botão de semente (parte de baixo) pra selecioná-la.
    - Clique num terreno de terra vazio (desbloqueado) pra plantar.
    - Espere a plantação amadurecer (ela brilha quando pronta) e clique
      pra colher.
    - Clique num terreno escuro/trancado pra comprá-lo com Ouro.
    - ESC fecha o jogo.
"""

import base64
import io
import math
import sys
import time

import pygame

# ------------------------------------------------------------------
# Sprites embutidos (base64) - gerados por gen_sprites.py
# ------------------------------------------------------------------

SPRITES_B64 = {
    "tile_grass": (
        "iVBORw0KGgoAAAANSUhEUgAAAIAAAABkCAYAAABO6zhfAAAEoklEQVR4nO2dPW4UQRCFnxEJIiNBhsBIpEBmhDgBEWcgI+IA"
        "SIRIHIALEHEAB4gTILRkmNSSkWAtMsQFTAC1ardmxj0zXV0/XV+GsKHa79XP9PS2gSAIgm558urxuXQMkuxJByAFCX/n4S2c"
        "brYAgI+vP3X38+huwanwOT0aoZuFTgmf05MR3C8Q+Cd+ifA5p5utexO4XtycrB/DezVwuagawud4NYKrxXAIn+PNCC4W0UL4"
        "HC9GMB08sHzAq4X1QVFt4G/OXpwDwMv9t4MxSmT9GJarwVXpAOaiSXiCYqHYLBnBjAFaC39wuA8A+P7lrPh7LBrhinQAJVCf"
        "15T1U1CsFl40qTeA9JC3BjKBZiOobAHpD6yF+EvKfSna24IqA6R9nkMMSbQaQYUBNE72XKRG0GAC8QBq9Xgq48D8Us7ZAqbQ"
        "sH8gVgF6yvoxNLSF5gZYKrxUlrZA0gjNDKA548lU0iaTMEKTfQBrGznStNxIYq0AmrPeAqkJuKoBiwEkhPc4GwD8baGqAbiE"
        "Tx/xPDFn5uAyQrUZoEWfX5PlB4f7TY3E9f/Vng9WVwBPfd5SG6k1Hyw2gCfhS5F+TMyp0RZmG6BH4bWzxgjFBuhR+LkZX/r1"
        "XLPIEiMUGUD6UIaWkpuTCr5EVK51zXnjOGkAT1nf2kQaTFsyKA4awJPwvXNZW7hgAO6NHA1ZASyPR0v8Sxgzwm4jKF7Y9EG+"
        "kbSrAD+//rrwRcGyjC/5HslKQqeQfv/4AyBrAakJgH6NUNoi0r/X3h5y4YnBIbBHI2ibU2oxJjwx+RgYbcE2p5vtqPBE0UbQ"
        "WiN4yyrtXJb1KcVbwZ7agldDzhGemP0yqNQIGnqqhhhasER4YvHrYE8VIceKYdYIT6w+EOJlULQiOlEy4JVQ7UwghxF6KeFz"
        "qJH1KVUPhaYm8HqQU4rawhMsx8JTI5xutqZbgzRcwhNsHwx5//zDhT9LmMB666jV56do8tlAL4NiK7izPmVngOOjkz0AuP/0"
        "Lsvn0SQfG60Mk62E//zu2+5QyOh5MS4jELcf3ARg/w6gGkgIT4y2gOOjkz1OE3jeSJpDiz4PDIsPXDIDcLcFoN/5QDLrU4qG"
        "wDBCPbQIT8x6CvA8KHKjTXhi8YcKuYdEoO2gyEXLR7q54gMVrolrZQSLJpAe8EqodtuEp8fGtWgt90NUv3emZyNYEp5guXio"
        "t/lAe5+fgvUeuh7mAwt9foomN1J6bAsWy/0QTe+m9WAEL8ITIrdUWzSCN+EJsWvKrQyKlge8EsR/X4DmQdH6gFeCuAEITW3B"
        "a7kfQjyAHEkj9CQ8oSaQlNbzgfc+P4WqYHJaGaFH4QmVQeVwGuH6jWtc/zQAvcITqoPL4TAClwG0C0+YCDKnphFqG8CK8IT6"
        "3x08BB1N04Y18QGjFSBlbTWoUQEsCk+YDTxnqRHWGMCy8IT5BeTMNcISA3gQnjA5A0zBPR94Eh9wWAFSSqpBaQXwJjzhclE5"
        "U0a4zABehSdcLy5nyAhjBvAuPOFuBpiidD7oRXygswqQQtUgrQA9CR/859Gze+xvHIMgCIIgCIIgCIIgCIIgCIIgCIJAhL9x"
        "y/uc8flSpgAAAABJRU5ErkJggg=="
    ),
    "tile_soil": (
        "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"
        "AElFTkSuQmCC"
    ),
    "tile_locked": (
        "iVBORw0KGgoAAAANSUhEUgAAAIAAAABkCAYAAABO6zhfAAAENElEQVR4nO2dvW4VMRCFJ4givEKUSCBFQEFBTYXEc0dKA3WK"
        "FAFFIlKuUgGvAAWZG2PWvvau7fnx+coom2vvOZ45d38cIgAAmJZPHz/8lh6DJEfSA5CChT87PaH73QMREV1cfpnufEw34VD4"
        "mBmNMM1Ec8LHzGQE9xMk+it+ifAx97sH9yZwPbmaVZ/CezVwOakWwsd4NYKryfQQPsabEVxMYoTwMV6MYHrwROsDXiusB0Wz"
        "A5dY9SksVwNzA9YkfIxFI5gZqGbhYywZQf0AieT7/Fos5APVg7O06lNorwYqB+VB+BitRlA1GI/Cx2gzgopBzCB8jJZ8ID4A"
        "qwGvBRqqgdgHp1b96/NXRET07fZ79d+0fOzF5WcRIzwf/YEzlvsSzk5P9udmpBGGGaBG+DUrycOxfG5GGuFZ7w8geurzh8Tn"
        "crgGT8fyuRrxxHLXCoByv40RbaGLASB8O3q3haYGaCG8dB/WemwvIzTLAKV9PoW2Pqz12Nb5YHMFQLmXoVU+WG0ACC9Pi7ZQ"
        "bYCewmvvw5qODdlihGID9BTeWh+WPDbHGiMUhcCtAQ+MpSYoZh2CPm+fQ3ccF38oKbz0XTlLx9aQMsI/GQAr3i+pfLDPAJr6"
        "vMVUruHbQAlxPthXgN1jieBfksBiKtf4bSAHt4KfP34RUdQCQhMQoRV4IhaeWbwOACP4ISU8k70QJNEWLPZhrf3/fveQFJ4p"
        "uhI4wggW+7DW/n9o1YcUXwpGW9BPjfBM9c0gGEEfa4RnVt8O7mEEi31Ysv9vEZ7Z/EBIi3xgsQ9L9/+SgFdCs2cCNVxImoEW"
        "qz5kf2PgzfnLZs+gnz4aAEZoR2vhiYiurm+OujwWjqDYjh7Ch3R9MQRtYRut+nyOIe8Gwgh19F71If89ENIyCyyBfJBmlPBX"
        "1zd73ZOPhMEI45AQnsk+E9jbBEQwwog+T7QsPlHhDiGjjDCTCSRXfUjVmyRoC9vRIjyz6p0yGKEebcIzq18qRD4oY+RXulrx"
        "iRrsEoZ8kEY64JXQbLcJtIUntJb7JZrvOzOzESwJz3TZeGi2fKC9z+foug/dDPnAQp/PMWRHSo9twWK5X2Lo3rQejOBFeEZk"
        "s2iLRvAmPCO2W7iVoGg54JUg/v8CNAdF6wGvBHEDMJragtdyv4T4AGIkjTCT8IyagYSMzgfe+3wOVYOJGWWEGYVnVA4qpqcR"
        "Xhwf9/rTRKRXeEb14GJ6GKGXAbQLz5gYZExLI7Q2gBXhmSH/M6g1X2/vVJ5ka+ITGa0AIVurQYsKYFF4xuzAY9YaYYsBLAvP"
        "mJ9ATK0R1hjAg/CMyQyQo3c+8CQ+kcMKEFJSDUorgDfhGZeTiskZ4ZABvArPuJ5czJIRUgbwLjzjLgPkKM0Hs4hPNFkFCOFq"
        "EFaAmYQHj7x/97b7HUcAAAAAAAAAAAAAAAAAAAAARPgDrOrdCytHHSIAAAAASUVORK5CYII="
    ),
    "crop_batata_0": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAABVklEQVR4nO3YIW4CURCH8WlTV8MV6rgBBgy6R6io4wocgSvg"
        "KnoENKY13KAOjoBBg1qy2eRBl52Z/xPfT5EQeG8+XtjNmgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAqvG+np/Ve2g8qzfQaKLU"
        "EqeKMN0YNcSRhylFUMeRhrk3vDKOLMx/h1bFkYTpO6wiTnqYR4fMjpMaZuhwmXHSwngNlRUnJYz3MBlxnqIXKOkz3GaxTd+n"
        "LEzbdDk5m5mN3l7tuD/Z72on35f8zrftuD+pt3D1olr4Yzb+al4fbrxnZvb98/cZvqGOtDDdYYd8NiNUeJghQe59Z2SgsDAR"
        "QUprRAQK+fPNiBK9nnuY7ChR61Z1ua6J642U6rS0ef3fcGIKCFPgGkZxhxq1PiemwD2M6tR4rxtyYrLjRKwX/twj8hIe+QOk"
        "PRDyDJRxImVPyvqEUl/tADzsAmH0dsOVamycAAAAAElFTkSuQmCC"
    ),
    "crop_batata_1": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAAB0UlEQVR4nO2YvU0FMRAG9wEBpdADgoiAIgjogJAaCOmAgCII"
        "iED0QCkEIIgsodPz/342RjPp3Xntud27tc0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAFmE3MtjF3el37Nrz7dvOzOzy/jx6z9PN"
        "y7D5ygOlZASOjg+rx1VLOlAOrpJils4sD2RilFICSjmu6Rgm+vnxlb23VUpq7PCd8qB7oO1bU0gpGXNLr6SuUlLXuVmbFLOy"
        "Uk7RLOYvSwn0yGkSs4KUQKucajErSQm0yHH/XZd8WL0XrkDSx/wHObIGb3U5VWJqa3VlOcVN0G8pyq61pnsupaXZK3pgX6b0"
        "7nPM8jvk3ibNrL0DzpZSbHK9b7Tk2KC3re95Pikm98Za5dScpbQurleqayqnyitI7J1wySmgB0deA5mN+cN4Lj6F9ARvZRAT"
        "ISnGO21HlYEH2YzxWsxKUswKS2lmPzGL4m/MrH5iFs2THtVPAKzBtJS/Ojt5KL338fX9WjeT/QwTUyMixwhRcjGeQrYoBcnE"
        "KIVsUQiS7JVGSlHFcxczWooqLrvrCK5iZmWLIj4ZEwExEVzFzOhQVfHJmAjuYmZljXdcScaMlqOIx14pArvrCJzHAICSH93D"
        "1j2m95ALAAAAAElFTkSuQmCC"
    ),
    "crop_batata_2": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAADKklEQVR4nO2asU4bQRCG5xKKPABFHoDCEk1EhRRMlcIPYcmU"
        "7tJY8jNEcpPOpS3xCBQpXIEtUSEapBRIvADpUyRyCjTRcr7d252dufOh/6vA3ttbf7c7Ozs2EQAAAAAAAAAAAAAAAAAAAAAA"
        "AAAAAAAAAIAiRVM3Gnw/3/re+/H1+tU4vnz77G27mm4aGbPpTUIyyvz5/Te5f0tJ76w6tpZCFJ5ZuZiIaUIKYyVHXUyTUhgL"
        "OSprlAd28OF99DW5UkL3KgdzCeIOqp6StZiU/hmpJNFSsgx6PiRSiNKWtkuymC5JYSRyksR0UQqTKidaTIyUlLgR84G1pDAp"
        "ctS3a205bWGS4L0FOWZHgq7LObDs3JWTkpC1EeTLJCU/mgOOPRmn7iahmZpyGq9tWB6YxvkmtVxQJ8eiZBGMMVUDyo0HkhpK"
        "KK23Kll4xYSeklROTmGpSo5lyaJyoG2t6xSs493OC9JDVwiNMoCLxa5VlmOWx3QdiPEAMR4gxsOOGO1Aqd0fkf5OV9Vf5YzR"
        "+jAWUhgtOb5+vEspN3mylMLkygldXymG8wSpHK3vi2KQyqm7bufNUPIUOgpUyWjqC3gXrR8EmNdB2pCjgWmhKoXZ+Mz7UCbz"
        "deNyWxfDQk5PjgJtaEvUrKDWxAz7vcWn48NRSAjDbWZj2jYlpzExw35v4f4fK8Xl9OSoMTlJu1Iqq+mmKAshkklxub17pPuH"
        "5+Xlzc+LjOEF2cljtHaRj1e/llVSNBn2ewure1QupdV0U6TOnMFTyefx4Yj/vH94XkoGF8uw31tozx5vjImVw0JqlsaIyFaQ"
        "tpxg8HWXVZWkwVNRJ4SIXkkbWc8eLcTxZDY+20oCKAdOaQDm633va80a0XYtlUL0f/bwzEmSc3v3SEQvu5r7usUsbDXzZTlE"
        "4RjFQgJt1GNY60cC58OMfG3qZpUbwy5v6EJjXK2LYcpPu+3MeC+L4TmZ8Ysc/0k9FpGYyXxd8LpPpW5X2RfEM0YipytSiDJj"
        "zGS+LrhWErOrdEUKkULw5UDHgkJtXKwPmLnsbT02J7N+s7sSkTyGaRWx9nbGMDE1YRaoWdn7B0E4mac7jNcYAAAAAElFTkSu"
        "QmCC"
    ),
    "crop_milho_0": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAABRklEQVR4nO3Yu00DQRCH8QGRQE4PFAEhjikAyRREESBRADkh"
        "TVCDySHE0Z2WFcvjbv4z7Or7hX7cnj+P72EzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEJX95cf2fswOcjegdJXYR63Tyn7mB5m"
        "c3s+xzg5Pf72tZGRjqIW8lBPlDJUV2FqylBdh6mVodZGGipMae00DRtmsnRyhg3DT6nAwbeiOG13HYbrmErEFXBXYbglKGTd"
        "RP7bMFlBJmlhri/O7szMdtXjb6/vn543M3t4frkJ2q1ZWJjyg7ZMUX56b0QoeZjfBFm6TWUgWRhFkNYaikCH3hs0i4miXs89"
        "THQU1bqSiRmB67VC1rSUvI43TEwDYRpcw2RcoarWZ2Ia3MNkTY33upKJiY6jWE9+a688hSu/gLD/PDwDRUxk2p9BfwmVfbYD"
        "sNgebwdsEc8+kEAAAAAASUVORK5CYII="
    ),
    "crop_milho_1": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAAB4klEQVR4nO3avU1DMRiF4RNEk/TZgSFCSWoGQApDMEaGAIkB"
        "UpMShmAG6KG8qRxZH7FIfL+fa+s8FQIFhxffPzsAEREREREREREREREREREREXVgFv0G1tvVkL5eLOf4+f4FALw9fYS+t+vI"
        "wU9ZLOcAgPuXuwEAdpt9SKDJhZFSIMA30uTD5PJIgG2opsJIlqGaDiNpHnZdhcmNnU3dhklqZ063YXgoZXjyFSwu202HsbyP"
        "CX0ekVeOc3ncAbuHqY0B+D4SmA80JgQQ9xCpPujYEElUkETl5KsVA8BxPSZaVRjNEFN1VfOi3WY/i57q1qrCJD0HUjnH5HF6"
        "OcxGzZhTeplF6mGS1gOZhUlaDTT5R4Ju7nwvMeVI4VN8vV0NaZPtUt0uOwB/t2jH4ApeAbdPzsDtk39w+0TgoZThyVfg9onA"
        "j4EIHnfATYXhJ6oy/AyeEL1UERbm4fbmGQC+xPfT9kn6OQC8vn8+Or2tI7cw+R9aUtpTkq/1CGUe5pwgtb/TMpBZGIsgpTEs"
        "Apms+XpEsR5PPYx3FKtxzXcJWqV6rxA1W3Ja5xvOmAKGKVANE3GHajU+Z0yBepioWaM9rsmM8Y5jMZ75o73lJdzyH+C25qEZ"
        "yGNGhi0GXRIq+mpHRNUONFe/bBv1TR8AAAAASUVORK5CYII="
    ),
    "crop_milho_2": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAACzUlEQVR4nO2cK0wDQRBApwRDScCAQFBdU0QNBgxJq4snAY1A"
        "o9FVCDRN8NQ3waAwCDDVRTSBGkgK8hDk4Niy7e7efLrHPEUK7d69zs7tzCQAKIqiKIqiKMp/oCR9AQAANxfVxHxt77gvem3i"
        "Ym4uqkmtXpl4/fF+ICqHdeGH6+2JyPBla/+O5ZrFvhFbpJhIRc4C94IA7lIAAGr1yp85iBoRMTGgOcYC+9712UZZuHMN61YK"
        "lQLAn2sWqRdodRo/NzN+ol4ODXQxv0QYrG2swnD4GvzZaxurwe/1BUXMNBlZRsNXCN1KAF95hosgMa4iYiYo+XYPe6XuYU+8"
        "zqIE5eZcI+hs5S33WlznGJQck42eaZJiyjHo55iibDPyGzAj6GT8FBQ13CdftoVanUYSU45hD/lWp5H4Ro1ET4a97RBL/hHp"
        "x+wd90uuT5jH+wGcL2+yHypFv71Z1XYqxQZl9ImH9bQpwTQpf4EpSlxMs72TnJZHE6/7SjHJK2kuxKQ/l9eXyNbxFUXeqJIm"
        "NHIKKybvViqUGMzkWwgxFI/tqMVQnmOiFMNRVog+rn2P+Zx1lkh17fP3UkUne6PKFekqnHXg5sL7ywfWpeSCdeAWEzpws6AD"
        "Nwu5OnhFFsQ6cIsJHbhZIGuGxy6IfEoQqyC28Ulsgua+iCxsrTSLZnsncW2CF7q6NskzJdBGlQVzK2rP10JWlE4JLOSNpsKK"
        "SdGBm4FupQyafA104Gag5xgDjhNwVGI4S4K5FyNVRM6tGOkWhZiYg93qJQDAs/F6OnBLfw8AcHXbP2K6rG/YxGRv1IZtCmm+"
        "l0MUuRgXIaGfSSmITAyFENsaFIJIer4cUqjXQxfDLYVqXf2nFxZQzwpS0ZIFK99oxFhQMRZQxUicUKnW14ixgC5GKmqw1yWJ"
        "GG45FOuRl/aUj3DKL4Ct54EpiCMixZpBPqKkn3aKogTzCUeXNsjwbS9+AAAAAElFTkSuQmCC"
    ),
    "crop_morango_0": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAABpElEQVR4nO3YMU7DMBTG8QdC7daVDTGhnoCJCrGwcoFKcBIG"
        "Zg7RSlyAEyDUrSdATBUbKxssMEUqURLq+H22Ff6/qaoSO/5iv1g2AwAAAAAAAAAAAAAAAAAAAAAAAAAAAPBP7KXs7PT2/Lvp"
        "//Xdc9Ln2IX8gdrCaFNKSPvKxkND6XuPgiyYmAGWEI4kGI+B5Q7HPRjPAeUM5yBXx6G6QlIUbPcGc75lz4CkX6XUPF/KoIIx"
        "8wvHPZgSNmge4UhmzBDCkS2lEsKJIa0xfcIZTcaKRwkm3cec3V/+ms5fH5+N19XDGE3GrdemIgumHopZ2GzIHY5kKTWF0kfM"
        "soqtcYPbx5j5FP7BBeP1NRxUMJ5bBPfiO59NFxvH9k6e3pdmZq8Xh9d/XbN27FfyVTp+fFturo5aBxLSTvW7GnwqrktpPpsu"
        "qt/bg+qjz/3b/ceS1pi+4cSG6kFefEMHWUIoZoITvK7p3FV3PAJ5WL3cxLZRSXrmW8ps2IX7UvJ8azn7ldSY1OEo+pMfJnl+"
        "QuuULyDZKZtnQClmZLbjx5CgctUtANF+AA1Gi02eFl9lAAAAAElFTkSuQmCC"
    ),
    "crop_morango_1": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAACB0lEQVR4nO3aMU7DMBTGcRch2FjZEBPiBEwgxMLKBZDgEMwM"
        "nTkESFyAlQVVMPUEiAmxsbLBAlOkyMpz/OzPUYX+v7WN+/Kltl/ahAAAAAAAAAAAAAAAAAAAAAAAAAAAAFbIrNXAB9fHv9Zr"
        "y/ki+3MPb07NcV6uHpvVLx84FUgsFVAqkFiLgNaUg3lCSb3fE0rJ+3PIgvGGYh1XepLqcCTBlIYSH197cspwqudmbSidja1N"
        "xTAhBM2aI11j/hOCMRCMgWAMxYtUfwf4+fquLmQ5X8wUu8pQLZ5Ou+M+wCq+Jpx+4TXhjNXgCcg1lVJFl263cbGlW23OhfG0"
        "FtnB5FxJbzjWFfSG4/m25oaTVUDJ1ztVrOruWjV9h4wWqGyzFR2pqtMOIR0O27WBYAwEY1if8sP668Pe0+dd7nHvZzsX1muK"
        "5nJIs10pZp1AKqBUILnjW8Z2paypVLubpIp+O9kePHlPKCH4eqicdiF7jWnZkcbheEPp5IST20O5Ft+WHWkXTmkonVQ4nsZS"
        "cncdq1kQVT9x9muY5O56iLIbVQVTuy7SxxgIxkAwBkkwJYvbEE83nLJS/yvVhtOFsvvwURWO6g9+6VQqDSf+ppSGo3zqQb7G"
        "eMOxpo83HPWjIM0evAkh3d+o7q5bPTzUNJi+86P9W9VY98+vl6qxLJMFE/MENUUQAJr4A+Op6KBqFxXRAAAAAElFTkSuQmCC"
    ),
    "crop_morango_2": (
        "iVBORw0KGgoAAAANSUhEUgAAAEYAAABaCAYAAAAFOiBkAAAD+UlEQVR4nO2aP0/cMBjGH6oKpBtQBySaBTFV1y/AUKVCXVh7"
        "M6oE880MTBmYGDpnBqliLitLVfXUoV8A1KnKkiJ1qG6IdLekw+Gr8dnO6z+XHNL7WxCXOLYfP3792gnAMAzDMAzDMAzDMAzD"
        "MAzDMAzDMAzDMAzDMAzDMAzDMAzDMNE4yA/qrtsgeNZ1AwRClFURZynCuHZOvX8VxIkujOvIm+7rWpyowriOfOj1ZbIW60G2"
        "TtwMb7T17GX78zLH+T0A4GK4DQD4cfY1Wtt8iOIY15Hfy/ZrWRRBmiRzgUz3+NTvQ/RRybf6NQAM/9w1ukRwnN8jTRIAwKgs"
        "564R2Nwji2Jypg9LWZXSJJkLJENxgOyapnLLXM2ehz4g/fi/MYfnxXzkVUydk91iYy/br2Xn2FazqgJGJ2Hu8S4sCyJQhRmV"
        "Ja5Od9DrAX9/T7TPMQmjm1LAbFpRnFFVD8/xFMhrKlFEEfR6s78vXm4sXKO6Ra27qmYdrypgkBUYZAXk34QoprZScBbGpaI0"
        "STDIivn/OnFsZdVYs76pL58mCQ7PC+01wE8cJ2FMFdhii4oQx9UtOlFc6nUVhyyMryVV1wB05wjXmJyi3mtzDeDWh+BViTpq"
        "cvD1iS2+9frSyrGDLl64lBVOEIGccm8oQcK4jtr65oa3W4Qovd7y3QJEmEpU0iQBHkZzVJbO5QdZgc9nO+R6rk6b77VBFmY6"
        "njwKgr6jJu+hbFsEkeWqydwg83fLdDxZyKBNNN6gNl6IEzKXTRtMFV2GSxVGZN2C6Xgx87YJZG2gaUSblk+bm0ZlSRZGRmxK"
        "qW6RhdGJIjCJYwy+NpvbKmrCtPOOjVihmtpq6qdWGMrxwHQ80Va6jBXD1S2u6Pq7YCPqqZkJ6nLsMqVCHabbpeuQp1XU5TpG"
        "RquSb/Vr9ZmyqKEDaaKzF24hsaaNOBVNmLbc0hZRp5JPRptv9evvr3GpvXhrLpcmCXKgvjKkDiErJ2DIY2LMWznXGZ3crH14"
        "279wKf/mFkdNblGTOB1UgdR8RjuVQl92qQmg71lOE5TdNOUsR9dfY4zxFcfUkF/vd46oz6C4JUabAHM/nfdKvg0Q7F4Xj+LJ"
        "z3fbC4K5BnLKlAIWp5X3XknGJhBFEJnd6+JSJwjgt7pRhQFm4kTZXQtixglbQPQ96QNAEof6nqm1gyoqtvTd1ZkhrMynZhRC"
        "cxMXnpQwQHvikIUJfUkuaHPUVVz64OSYUHGeiiiAx1TyFecpiQJ4xhjXitSkrk18BzI4btjyG3XzaErqXHj15X4usm2b0dmH"
        "Q64IgULEEaJ8+nZ3HKdVZjr5ZNTnWKPtz1s7yWNcO9nFN7+dfmQM0F7TMivEP708/DOpFiMCAAAAAElFTkSuQmCC"
    ),
    "farmhouse": (
        "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"
        "tooDQQAAAABJRU5ErkJggg=="
    ),
    "fence": (
        "iVBORw0KGgoAAAANSUhEUgAAAFoAAAA8CAYAAADmBa1FAAABs0lEQVR4nO3bMU4DMRCFYQdxEXoKehqUPuIKOUKaiDNEaThC"
        "roDoIxp6CnouQEFDnRTIaNn1DjbMTubZ7ythlbC/bOIdRAhEREREFma5F25Wi0PutXf3j9mv65X2/Z6XvPn11cWv1zy/vJW8"
        "pGua91sUmmTr5fzHLtju9t8rnaELPTy9Dr4WA3d3QH+lM3TCejk/vH98JqPm/DpJaTp0f6tHf40pqT70WMwQpgk6porQXmJK"
        "YEIjxJS4Co0eU2IeuuaY0sPLZKEtP9EtSTG7Dyh9/wqdOmeG8BUZOagU8/bmcnCtyqwjrszUAR45ZgjjQbe7/WyzWqgulkHo"
        "/pavNWYI8lbXllzRaHG9xJS4Ot5JEGLCTO8QYsJM7xBiQk3vpE/0qd6zFMz0DmV1jn3P1fSu5PAer7f+46yXmJJk6G7cuDK1"
        "D/ClEGJKBqFPueXRY0o4vVPE6Z0iTu8UcXqnjNM7RV7O+pzeGXE1VJIgxJS4Co0eU8LpnZGmp3eWqp/eeVHF9A4BzPQOnavp"
        "Xc3OTv0DtIKhjTC0EYY2wtBGGNpI0ZNhTf9+nKO1+yUiIiIiokYdAaiHBwk1X2iYAAAAAElFTkSuQmCC"
    ),
    "chicken": (
        "iVBORw0KGgoAAAANSUhEUgAAADIAAAA2CAYAAACFrsqnAAACCklEQVR4nO2YIW8CMRTH/yxT0ygEiiwosqBOoMgkn2ISjZ6Y"
        "Rk/yKZAEdQJFCOpCUBNTp2eZ2Ho0l3vX9l17baA/dcuu5f3yXq+vBSKRSCQSidwOHd8BHHfrC/W/UTLTjs+biBAYvkzId7JD"
        "CkBPyIvIcbe+1AmUyQ6pUuahcVSGmEoAf1mrK0Gg5YzoSoyeB9cxp3PxXJeZ1jOiQpao+puiNRFOScnkq6S2xB7ZM3sgXyXo"
        "Avj+HF4AoDfPijILTuR4OpNrpIwQAgIUAeqDr6I3zzrORFSfSxs4Ky05+KqFnR3S2p1cF1lAYEVEp92wQT5ekvtI4w2R025w"
        "hFVtClukSRZMZXR6LZZI080NuHa2trpfb59fISCCFTwt3q/PBvMZZ8RGNqr4ep0q3xmkezJeo17LpwQAnCdjcm8Krvvloi3i"
        "OxsCKiv3l5HQ8S7S32yN3qe+XN5FbBGEiG5WrO0jLulvtqRQf7PFz/KjdrzRzu7qE6wiyAs6VxiJjJJZp9zkuUYnGwAjI23K"
        "6EoAN1RaXk6IKkwOVILWz+wqTMpJhl1a4pZPrBlq3eSrRGs+MQdHAmh41C3uYP9/nLrXkmW6b7viWZbnCghYg+U7Vxn54kxI"
        "dfcLcp6qizYu1kSooHSkbWBcWuXAOAHZlgAa7iOhSACGInI2QpIAGKXFDcalhBHUonU17m75BbFx/t+CtwluAAAAAElFTkSu"
        "QmCC"
    ),
    "coin_ouro": (
        "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABGUlEQVR4nO2XuxHCMBBEBUMFjiiAPlyBM2qALgjoAmogcwXu"
        "gwKI3AJEZ8Rxv8X2oBnY0Dp7n1ayPin9uhafvHQ6bO5a2/54hb4ZLrZMx8CEALj5brtWa8+XGwRhNubGlmkERgNZzmXO39OG"
        "UKTyzNuuf3vW1JUKYiWhJiCZt10vmnttVoJvCVDvJXOS1FuvPaVnEnkKLwCeuRVztJZDmEOAmud12nBwuQBzawCQ4kd7T7JS"
        "oO+TXzkJ/AGKBEB/KRIyectJgFYmvp+jKUy+EnKIyGaErBuraGFTV4OBlQa6aIV3w1zoeYDk7oYIBCrJPCVnDvAJOdZckgiQ"
        "U46F8A6magJTQEROxWXfCyyIiCa7GSEw6N3w63oAMT62ZQiIijcAAAAASUVORK5CYII="
    ),
    "coin_moeda": (
        "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAABFElEQVR4nO2XzQ2CQBCFV2NBlOANqjCUYGIdJpZArAJulmBH"
        "ehpch/l7AnETfUd24H37dtmflH5dm09eupzbh9Z2PHXQN8PFlukcmBAAN28Pe7W2u94gCLMxN7ZMIzAayHYtc/6eNoQilWfe"
        "D/fJs6auVBArCTUBybwf7qK512YlOEmAei+Zk6Teeu0pvZLIU3gD8MytmKO1HMIcAtQ8r9OGg8sFWFsjgBQ/2nuSlQJ9n/zK"
        "SeAPUCQA+kuRkMlbTgK0MvH9HE1h8ZWQQ0Q2I2Td2EULm7oaDaw00EUrvBvmQs8DJHc3RCBQSeYpOXOAT8i55pJEgJxyLoR3"
        "MFUTWAIiciou+15gQUS02M0IgUHvhl/XE4++tMNAF4w3AAAAAElFTkSuQmCC"
    ),
}


def load_sprite(name):
    raw = base64.b64decode(SPRITES_B64[name])
    return pygame.image.load(io.BytesIO(raw)).convert_alpha()


# ------------------------------------------------------------------
# Configuração geral
# ------------------------------------------------------------------

pygame.init()

WIDTH, HEIGHT = 1000, 720
SCREEN = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Mini Fazenda - Demo (fan tribute)")
CLOCK = pygame.time.Clock()

FONT_SM = pygame.font.SysFont("arial", 15)
FONT_MD = pygame.font.SysFont("arial", 19, bold=True)
FONT_LG = pygame.font.SysFont("arial", 27, bold=True)

COLOR_SKY = (150, 205, 130)
COLOR_HUD_BG = (76, 56, 36)
COLOR_HUD_BG2 = (96, 72, 46)
COLOR_TEXT = (255, 255, 255)
COLOR_GOLD = (255, 210, 60)
COLOR_COIN = (255, 240, 150)
COLOR_PANEL = (86, 62, 40)
COLOR_READY_GLOW = (255, 255, 120)

SPRITES = {name: load_sprite(name) for name in SPRITES_B64}

# ------------------------------------------------------------------
# Grid isométrico
# ------------------------------------------------------------------

TILE_W, TILE_H = 128, 74  # tamanho da face de cima do tile (topo do losango)
COLS, ROWS = 5, 4
STARTING_UNLOCKED = 10  # quantos terrenos já vêm liberados (dá pra plantar)

ORIGIN_X = WIDTH // 2
ORIGIN_Y = 300


def tile_center(col, row):
    x = ORIGIN_X + (col - row) * (TILE_W // 2)
    y = ORIGIN_Y + (col + row) * (TILE_H // 2)
    return x, y


def point_in_tile(px, py, col, row):
    cx, cy = tile_center(col, row)
    dx = abs(px - cx) / (TILE_W / 2)
    dy = abs(py - cy) / (TILE_H / 2)
    return (dx + dy) <= 1.0


# ------------------------------------------------------------------
# Definição das plantações
# ------------------------------------------------------------------

CROPS = {
    "batata": {"nome": "Batata", "custo": 5, "tempo": 8, "venda": 12, "xp": 5, "nivel_min": 1},
    "milho": {"nome": "Milho", "custo": 10, "tempo": 15, "venda": 22, "xp": 10, "nivel_min": 1},
    "morango": {"nome": "Morango", "custo": 20, "tempo": 25, "venda": 45, "xp": 18, "nivel_min": 3},
}
CROP_ORDER = ["batata", "milho", "morango"]


def sprite_stage(crop_id, pct):
    if pct >= 1.0:
        idx = 2
    elif pct >= 0.45:
        idx = 1
    else:
        idx = 0
    return SPRITES[f"crop_{crop_id}_{idx}"]


# ------------------------------------------------------------------
# Estado do jogo
# ------------------------------------------------------------------

plots = []
for i in range(COLS * ROWS):
    plots.append({
        "unlocked": i < STARTING_UNLOCKED,
        "custo_ouro": 30 + max(0, i - STARTING_UNLOCKED) * 15,
        "crop": None,
        "planted_at": None,
    })

state = {
    "moedas": 40,
    "ouro": 90,
    "nivel": 1,
    "xp": 0,
    "xp_meta": 30,
    "selected_crop": "batata",
}

floaters = []


def add_floater(text, pos, color=COLOR_TEXT):
    floaters.append({"text": text, "pos": pos, "color": color, "t0": time.time()})


def crops_disponiveis():
    return [c for c in CROP_ORDER if CROPS[c]["nivel_min"] <= state["nivel"]]


def ouro_por_nivel(nivel):
    # Cresce um pouco mais rápido que o custo dos terrenos (30 + 15*extra),
    # pra cada level up sempre dar pra desbloquear (ou chegar perto de)
    # um novo terreno.
    return 20 + (nivel - 1) * 10


def ganhar_xp(qtd):
    state["xp"] += qtd
    while state["xp"] >= state["xp_meta"]:
        state["xp"] -= state["xp_meta"]
        state["nivel"] += 1
        state["xp_meta"] = 30 + (state["nivel"] - 1) * 20
        ouro_ganho = ouro_por_nivel(state["nivel"])
        state["ouro"] += ouro_ganho
        add_floater(f"Nivel {state['nivel']}!", (WIDTH // 2 - 40, HEIGHT // 2), COLOR_GOLD)
        add_floater(f"+{ouro_ganho} ouro", (WIDTH // 2 - 30, HEIGHT // 2 + 24), COLOR_GOLD)
        for c in CROP_ORDER:
            if CROPS[c]["nivel_min"] == state["nivel"]:
                add_floater(f"{CROPS[c]['nome']} liberado!", (WIDTH // 2 - 60, HEIGHT // 2 + 48), (150, 255, 150))


# ------------------------------------------------------------------
# Ações
# ------------------------------------------------------------------

def tentar_plantar(index):
    plot = plots[index]
    if not plot["unlocked"] or plot["crop"] is not None:
        return
    crop_id = state["selected_crop"]
    crop = CROPS[crop_id]
    col, row = index % COLS, index // COLS
    pos = tile_center(col, row)
    if crop["nivel_min"] > state["nivel"]:
        add_floater("Bloqueado!", pos, (255, 120, 120))
        return
    if state["moedas"] < crop["custo"]:
        add_floater("Moedas insuf.!", pos, (255, 120, 120))
        return
    state["moedas"] -= crop["custo"]
    plot["crop"] = crop_id
    plot["planted_at"] = time.time()


def tentar_colher(index):
    plot = plots[index]
    if plot["crop"] is None:
        return
    crop = CROPS[plot["crop"]]
    elapsed = time.time() - plot["planted_at"]
    if elapsed < crop["tempo"]:
        return
    col, row = index % COLS, index // COLS
    pos = tile_center(col, row)
    state["moedas"] += crop["venda"]
    ganhar_xp(crop["xp"])
    add_floater(f"+{crop['venda']} moedas", (pos[0] - 20, pos[1] - 40), COLOR_COIN)
    plot["crop"] = None
    plot["planted_at"] = None


def tentar_desbloquear(index):
    plot = plots[index]
    if plot["unlocked"]:
        return
    custo = plot["custo_ouro"]
    col, row = index % COLS, index // COLS
    pos = tile_center(col, row)
    if state["ouro"] < custo:
        add_floater("Ouro insuf.!", pos, (255, 120, 120))
        return
    state["ouro"] -= custo
    plot["unlocked"] = True
    add_floater("Terreno novo!", pos, (150, 255, 150))


# ------------------------------------------------------------------
# Layout dos botões de semente
# ------------------------------------------------------------------

CROP_BUTTON_Y = HEIGHT - 86
CROP_BUTTON_W = 230
CROP_BUTTON_H = 62
CROP_BUTTON_GAP = 18


def crop_button_rect(i):
    total_w = len(CROP_ORDER) * CROP_BUTTON_W + (len(CROP_ORDER) - 1) * CROP_BUTTON_GAP
    left = (WIDTH - total_w) // 2
    x = left + i * (CROP_BUTTON_W + CROP_BUTTON_GAP)
    return pygame.Rect(x, CROP_BUTTON_Y, CROP_BUTTON_W, CROP_BUTTON_H)


# ------------------------------------------------------------------
# Desenho
# ------------------------------------------------------------------

def draw_hud():
    pygame.draw.rect(SCREEN, COLOR_HUD_BG, (0, 0, WIDTH, 66))
    pygame.draw.rect(SCREEN, COLOR_HUD_BG2, (0, 62, WIDTH, 4))
    titulo = FONT_LG.render("Mini Fazenda - Demo", True, COLOR_TEXT)
    SCREEN.blit(titulo, (18, 6))

    nivel_txt = FONT_MD.render(f"Nivel {state['nivel']}", True, COLOR_GOLD)
    SCREEN.blit(nivel_txt, (18, 38))

    bar_x, bar_y, bar_w, bar_h = 118, 42, 150, 13
    pygame.draw.rect(SCREEN, (40, 30, 20), (bar_x, bar_y, bar_w, bar_h))
    pct = max(0.0, min(1.0, state["xp"] / state["xp_meta"]))
    pygame.draw.rect(SCREEN, (255, 165, 40), (bar_x, bar_y, int(bar_w * pct), bar_h))
    pygame.draw.rect(SCREEN, (20, 15, 10), (bar_x, bar_y, bar_w, bar_h), 2)

    moeda_icon = SPRITES["coin_moeda"]
    ouro_icon = SPRITES["coin_ouro"]
    SCREEN.blit(moeda_icon, (330, 12))
    moedas_txt = FONT_MD.render(f"{state['moedas']}", True, COLOR_COIN)
    SCREEN.blit(moedas_txt, (366, 16))
    SCREEN.blit(ouro_icon, (330, 40))
    ouro_txt = FONT_MD.render(f"{state['ouro']}", True, COLOR_GOLD)
    SCREEN.blit(ouro_txt, (366, 44))

    ajuda = FONT_SM.render("ESC para sair", True, (220, 220, 220))
    SCREEN.blit(ajuda, (WIDTH - 120, 24))


def draw_scene():
    order = sorted(range(COLS * ROWS), key=lambda idx: (idx % COLS) + (idx // COLS))
    for index in order:
        col, row = index % COLS, index // COLS
        cx, cy = tile_center(col, row)
        plot = plots[index]
        img = SPRITES["tile_locked"] if not plot["unlocked"] else (
            SPRITES["tile_soil"] if plot["crop"] is not None else SPRITES["tile_grass"]
        )
        SCREEN.blit(img, (cx - img.get_width() // 2, cy - TILE_H // 2))

        if not plot["unlocked"]:
            custo = FONT_SM.render(f"{plot['custo_ouro']} ouro", True, COLOR_GOLD)
            SCREEN.blit(custo, custo.get_rect(center=(cx, cy + 8)))
            continue

        if plot["crop"] is None:
            continue

        crop = CROPS[plot["crop"]]
        elapsed = time.time() - plot["planted_at"]
        pct = max(0.0, min(1.0, elapsed / crop["tempo"]))
        pronto = pct >= 1.0
        img = sprite_stage(plot["crop"], pct)

        if pronto:
            glow = 4 + int(3 * abs((time.time() * 3) % 2 - 1))
            pygame.draw.ellipse(
                SCREEN, COLOR_READY_GLOW,
                (cx - TILE_W // 2 + glow, cy - 6, TILE_W - glow * 2, 22), 3,
            )

        SCREEN.blit(img, (cx - img.get_width() // 2, cy - img.get_height() + 24))

        if not pronto:
            bar_w = 60
            bar_x = cx - bar_w // 2
            bar_y = cy + 16
            pygame.draw.rect(SCREEN, (40, 30, 20), (bar_x, bar_y, bar_w, 6))
            pygame.draw.rect(SCREEN, (120, 220, 120), (bar_x, bar_y, int(bar_w * pct), 6))


def draw_decorations():
    house_full = SPRITES["farmhouse"]
    scale = 0.72
    house = pygame.transform.smoothscale(
        house_full, (int(house_full.get_width() * scale), int(house_full.get_height() * scale))
    )
    hx = ORIGIN_X + (COLS - ROWS) * (TILE_W // 4)
    hy = 78
    SCREEN.blit(house, (hx - house.get_width() // 2, hy))

    chicken = SPRITES["chicken"]
    SCREEN.blit(chicken, (hx + 90, hy + house.get_height() - 40))

    fence = SPRITES["fence"]
    for i in range(-1, COLS + 1):
        fx, fy = tile_center(i, -1)
        SCREEN.blit(fence, (fx - fence.get_width() // 2, fy - fence.get_height() // 2 + 6))
    for i in range(-1, ROWS + 1):
        fx, fy = tile_center(-1, i)
        SCREEN.blit(fence, (fx - fence.get_width() // 2, fy - fence.get_height() // 2 + 6))


def draw_crop_buttons():
    disponiveis = crops_disponiveis()
    for i, crop_id in enumerate(CROP_ORDER):
        rect = crop_button_rect(i)
        crop = CROPS[crop_id]
        bloqueado = crop_id not in disponiveis
        cor_fundo = (50, 40, 30) if bloqueado else COLOR_PANEL
        pygame.draw.rect(SCREEN, cor_fundo, rect, border_radius=8)
        borda = (255, 255, 255) if (crop_id == state["selected_crop"] and not bloqueado) else (60, 45, 30)
        pygame.draw.rect(SCREEN, borda, rect, 3, border_radius=8)

        icon = SPRITES[f"crop_{crop_id}_2"]
        icon_small = pygame.transform.smoothscale(icon, (40, 50))
        SCREEN.blit(icon_small, (rect.x + 8, rect.y + 6))

        if bloqueado:
            nome = FONT_MD.render(f"{crop['nome']} (Nv.{crop['nivel_min']})", True, (150, 150, 150))
            SCREEN.blit(nome, (rect.x + 56, rect.y + 18))
        else:
            nome = FONT_MD.render(crop["nome"], True, COLOR_TEXT)
            SCREEN.blit(nome, (rect.x + 56, rect.y + 4))
            info = FONT_SM.render(
                f"{crop['custo']} moedas | {crop['tempo']}s | vende {crop['venda']}", True, (220, 220, 220)
            )
            SCREEN.blit(info, (rect.x + 56, rect.y + 30))


def draw_floaters():
    now = time.time()
    for f in floaters[:]:
        dt = now - f["t0"]
        if dt > 1.2:
            floaters.remove(f)
            continue
        offset = int(dt * 30)
        txt = FONT_MD.render(f["text"], True, f["color"])
        SCREEN.blit(txt, (f["pos"][0], f["pos"][1] - offset))


# ------------------------------------------------------------------
# Loop principal
# ------------------------------------------------------------------

def handle_click(pos):
    for i, crop_id in enumerate(CROP_ORDER):
        if crop_button_rect(i).collidepoint(pos):
            if crop_id in crops_disponiveis():
                state["selected_crop"] = crop_id
            return

    for index in range(COLS * ROWS):
        col, row = index % COLS, index // COLS
        if point_in_tile(pos[0], pos[1], col, row):
            plot = plots[index]
            if not plot["unlocked"]:
                tentar_desbloquear(index)
            elif plot["crop"] is None:
                tentar_plantar(index)
            else:
                tentar_colher(index)
            return


def main():
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
                handle_click(event.pos)

        SCREEN.fill(COLOR_SKY)
        draw_decorations()
        draw_scene()
        draw_hud()
        draw_crop_buttons()
        draw_floaters()

        pygame.display.flip()
        CLOCK.tick(60)

    pygame.quit()
    sys.exit()


if __name__ == "__main__":
    main()
