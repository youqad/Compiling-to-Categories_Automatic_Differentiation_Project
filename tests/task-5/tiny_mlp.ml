open Category
module Make (C : sig
  include CartesianClosedCat
  val ok_float: float ok
  include NumCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
  include FloatingCat
  with type t := float
  with type ('a, 'b) k := ('a, 'b) k
end) = struct
  include CartesianCatDerivedOperations (C)
  open C
let t_1 = negC

let t_2 = expC

let t_3 = ok_float

let t_4 = compose t_3 t_3 t_3

let t_5 = t_4 t_2

let t_6 = t_5 t_1

let t_7 = it t_3

let t_8 = 1.

let t_9 = unit_arrow t_3

let t_10 = t_9 t_8

let t_11 = ok_unit

let t_12 = compose t_3 t_11 t_3

let t_13 = t_12 (t_10)

let t_14 = t_13 (t_7)

let t_15 = fork t_3 t_3 t_3

let t_16 = t_15 (t_14)

let t_17 = t_16 (t_6)

let t_18 = addC

let t_19 = (ok_pair t_3 t_3)

let t_20 = compose t_3 t_19 t_3

let t_21 = t_20 t_18

let t_22 = t_21 (t_17)

let t_23 = invC

let t_24 = t_4 t_23

let t_25 = t_24 (t_22)

let t_26 = exl t_19 t_19

let t_27 = exl t_3 t_3

let t_28 = (ok_pair t_19 t_19)

let t_29 = compose t_28 t_19 t_3

let t_30 = t_29 (t_27)

let t_31 = t_30 (t_26)

let t_32 = id t_28

let t_33 = fork t_28 t_28 t_3

let t_34 = t_33 (t_32)

let t_35 = t_34 (t_31)

let t_36 = exl t_28 t_3

let t_37 = (ok_pair t_28 t_3)

let t_38 = compose t_37 t_28 t_19

let t_39 = t_38 (t_26)

let t_40 = t_39 (t_36)

let t_41 = exr t_3 t_3

let t_42 = compose t_37 t_19 t_3

let t_43 = t_42 (t_41)

let t_44 = t_43 (t_40)

let t_45 = id t_37

let t_46 = fork t_37 t_37 t_3

let t_47 = t_46 (t_45)

let t_48 = t_47 (t_44)

let t_49 = exl t_37 t_3

let t_50 = (ok_pair t_37 t_3)

let t_51 = compose t_50 t_37 t_28

let t_52 = t_51 (t_36)

let t_53 = t_52 (t_49)

let t_54 = exr t_19 t_19

let t_55 = compose t_50 t_28 t_19

let t_56 = t_55 (t_54)

let t_57 = t_56 (t_53)

let t_58 = compose t_50 t_19 t_3

let t_59 = t_58 (t_27)

let t_60 = t_59 (t_57)

let t_61 = id t_50

let t_62 = fork t_50 t_50 t_3

let t_63 = t_62 (t_61)

let t_64 = t_63 (t_60)

let t_65 = exl t_50 t_3

let t_66 = (ok_pair t_50 t_3)

let t_67 = compose t_66 t_50 t_28

let t_68 = t_67 (t_53)

let t_69 = t_68 (t_65)

let t_70 = compose t_66 t_28 t_19

let t_71 = t_70 (t_54)

let t_72 = t_71 (t_69)

let t_73 = compose t_66 t_19 t_3

let t_74 = t_73 (t_41)

let t_75 = t_74 (t_72)

let t_76 = id t_66

let t_77 = fork t_66 t_66 t_3

let t_78 = t_77 (t_76)

let t_79 = t_78 (t_75)

let t_80 = exl t_66 t_3

let t_81 = exr t_37 t_3

let t_82 = compose t_66 t_50 t_3

let t_83 = t_82 (t_81)

let t_84 = t_83 (t_65)

let t_85 = (ok_pair t_66 t_3)

let t_86 = compose t_85 t_66 t_3

let t_87 = t_86 (t_84)

let t_88 = t_87 (t_80)

let t_89 = exr t_66 t_3

let t_90 = fork t_85 t_3 t_3

let t_91 = t_90 (t_89)

let t_92 = t_91 (t_88)

let t_93 = mulC

let t_94 = compose t_85 t_19 t_3

let t_95 = t_94 t_93

let t_96 = t_95 (t_92)

let t_97 = exr t_28 t_3

let t_98 = compose t_50 t_37 t_3

let t_99 = t_98 (t_97)

let t_100 = t_99 (t_49)

let t_101 = t_82 (t_100)

let t_102 = t_101 (t_65)

let t_103 = t_86 (t_102)

let t_104 = t_103 (t_80)

let t_105 = exr t_50 t_3

let t_106 = t_86 (t_105)

let t_107 = t_106 (t_80)

let t_108 = t_90 (t_107)

let t_109 = t_108 (t_104)

let t_110 = t_95 (t_109)

let t_111 = t_90 (t_110)

let t_112 = t_111 (t_96)

let t_113 = t_94 t_18

let t_114 = t_113 (t_112)

let t_115 = id t_85

let t_116 = fork t_85 t_85 t_3

let t_117 = t_116 (t_115)

let t_118 = t_117 (t_114)

let t_119 = exr t_85 t_3

let t_120 = (ok_pair t_85 t_3)

let t_121 = compose t_120 t_3 t_3

let t_122 = t_121 t_1

let t_123 = t_122 (t_119)

let t_124 = t_121 t_2

let t_125 = t_124 (t_123)

let t_126 = it t_120

let t_127 = compose t_120 t_11 t_3

let t_128 = t_127 (t_10)

let t_129 = t_128 (t_126)

let t_130 = fork t_120 t_3 t_3

let t_131 = t_130 (t_129)

let t_132 = t_131 (t_125)

let t_133 = compose t_120 t_19 t_3

let t_134 = t_133 t_18

let t_135 = t_134 (t_132)

let t_136 = t_121 t_23

let t_137 = t_136 (t_135)

let t_138 = compose t_85 t_120 t_3

let t_139 = t_138 (t_137)

let t_140 = t_139 (t_118)

let t_141 = compose t_66 t_85 t_3

let t_142 = t_141 (t_140)

let t_143 = t_142 (t_79)

let t_144 = compose t_50 t_66 t_3

let t_145 = t_144 (t_143)

let t_146 = t_145 (t_64)

let t_147 = compose t_37 t_50 t_3

let t_148 = t_147 (t_146)

let t_149 = t_148 (t_48)

let t_150 = compose t_28 t_37 t_3

let t_151 = t_150 (t_149)

let t_152 = t_151 (t_35)

let t_153 = t_47 (t_97)

let t_154 = fork t_50 t_50 t_28

let t_155 = t_154 (t_61)

let t_156 = t_155 (t_53)

let t_157 = exr t_50 t_28

let t_158 = (ok_pair t_50 t_28)

let t_159 = compose t_158 t_28 t_19

let t_160 = t_159 (t_26)

let t_161 = t_160 (t_157)

let t_162 = compose t_158 t_19 t_3

let t_163 = t_162 (t_27)

let t_164 = t_163 (t_161)

let t_165 = id t_158

let t_166 = fork t_158 t_158 t_3

let t_167 = t_166 (t_165)

let t_168 = t_167 (t_164)

let t_169 = exl t_158 t_3

let t_170 = (ok_pair t_158 t_3)

let t_171 = compose t_170 t_158 t_28

let t_172 = t_171 (t_157)

let t_173 = t_172 (t_169)

let t_174 = compose t_170 t_28 t_19

let t_175 = t_174 (t_26)

let t_176 = t_175 (t_173)

let t_177 = compose t_170 t_19 t_3

let t_178 = t_177 (t_41)

let t_179 = t_178 (t_176)

let t_180 = id t_170

let t_181 = fork t_170 t_170 t_3

let t_182 = t_181 (t_180)

let t_183 = t_182 (t_179)

let t_184 = exl t_170 t_3

let t_185 = (ok_pair t_170 t_3)

let t_186 = compose t_185 t_170 t_28

let t_187 = t_186 (t_173)

let t_188 = t_187 (t_184)

let t_189 = compose t_185 t_28 t_19

let t_190 = t_189 (t_54)

let t_191 = t_190 (t_188)

let t_192 = compose t_185 t_19 t_3

let t_193 = t_192 (t_27)

let t_194 = t_193 (t_191)

let t_195 = id t_185

let t_196 = fork t_185 t_185 t_3

let t_197 = t_196 (t_195)

let t_198 = t_197 (t_194)

let t_199 = exl t_185 t_3

let t_200 = (ok_pair t_185 t_3)

let t_201 = compose t_200 t_185 t_28

let t_202 = t_201 (t_188)

let t_203 = t_202 (t_199)

let t_204 = compose t_200 t_28 t_19

let t_205 = t_204 (t_54)

let t_206 = t_205 (t_203)

let t_207 = compose t_200 t_19 t_3

let t_208 = t_207 (t_41)

let t_209 = t_208 (t_206)

let t_210 = id t_200

let t_211 = fork t_200 t_200 t_3

let t_212 = t_211 (t_210)

let t_213 = t_212 (t_209)

let t_214 = exl t_200 t_3

let t_215 = exr t_170 t_3

let t_216 = compose t_200 t_185 t_3

let t_217 = t_216 (t_215)

let t_218 = t_217 (t_199)

let t_219 = (ok_pair t_200 t_3)

let t_220 = compose t_219 t_200 t_3

let t_221 = t_220 (t_218)

let t_222 = t_221 (t_214)

let t_223 = exr t_200 t_3

let t_224 = fork t_219 t_3 t_3

let t_225 = t_224 (t_223)

let t_226 = t_225 (t_222)

let t_227 = compose t_219 t_19 t_3

let t_228 = t_227 t_93

let t_229 = t_228 (t_226)

let t_230 = exr t_158 t_3

let t_231 = compose t_185 t_170 t_3

let t_232 = t_231 (t_230)

let t_233 = t_232 (t_184)

let t_234 = t_216 (t_233)

let t_235 = t_234 (t_199)

let t_236 = t_220 (t_235)

let t_237 = t_236 (t_214)

let t_238 = exr t_185 t_3

let t_239 = t_220 (t_238)

let t_240 = t_239 (t_214)

let t_241 = t_224 (t_240)

let t_242 = t_241 (t_237)

let t_243 = t_228 (t_242)

let t_244 = t_224 (t_243)

let t_245 = t_244 (t_229)

let t_246 = t_227 t_18

let t_247 = t_246 (t_245)

let t_248 = id t_219

let t_249 = fork t_219 t_219 t_3

let t_250 = t_249 (t_248)

let t_251 = t_250 (t_247)

let t_252 = exr t_219 t_3

let t_253 = (ok_pair t_219 t_3)

let t_254 = compose t_253 t_3 t_3

let t_255 = t_254 t_1

let t_256 = t_255 (t_252)

let t_257 = t_254 t_2

let t_258 = t_257 (t_256)

let t_259 = it t_253

let t_260 = compose t_253 t_11 t_3

let t_261 = t_260 (t_10)

let t_262 = t_261 (t_259)

let t_263 = fork t_253 t_3 t_3

let t_264 = t_263 (t_262)

let t_265 = t_264 (t_258)

let t_266 = compose t_253 t_19 t_3

let t_267 = t_266 t_18

let t_268 = t_267 (t_265)

let t_269 = t_254 t_23

let t_270 = t_269 (t_268)

let t_271 = compose t_219 t_253 t_3

let t_272 = t_271 (t_270)

let t_273 = t_272 (t_251)

let t_274 = compose t_200 t_219 t_3

let t_275 = t_274 (t_273)

let t_276 = t_275 (t_213)

let t_277 = compose t_185 t_200 t_3

let t_278 = t_277 (t_276)

let t_279 = t_278 (t_198)

let t_280 = compose t_170 t_185 t_3

let t_281 = t_280 (t_279)

let t_282 = t_281 (t_183)

let t_283 = compose t_158 t_170 t_3

let t_284 = t_283 (t_282)

let t_285 = t_284 (t_168)

let t_286 = compose t_50 t_158 t_3

let t_287 = t_286 (t_285)

let t_288 = t_287 (t_156)

let t_289 = t_63 (t_288)

let t_290 = compose t_66 t_3 t_3

let t_291 = t_290 t_1

let t_292 = t_291 (t_105)

let t_293 = fork t_66 t_3 t_3

let t_294 = t_293 (t_292)

let t_295 = t_294 (t_84)

let t_296 = t_73 t_18

let t_297 = t_296 (t_295)

let t_298 = t_78 (t_297)

let t_299 = it t_85

let t_300 = 0.5

let t_301 = t_9 t_300

let t_302 = compose t_85 t_11 t_3

let t_303 = t_302 (t_301)

let t_304 = t_303 (t_299)

let t_305 = t_90 (t_304)

let t_306 = t_305 (t_89)

let t_307 = t_95 (t_306)

let t_308 = t_90 (t_307)

let t_309 = t_308 (t_89)

let t_310 = t_95 (t_309)

let t_311 = t_141 (t_310)

let t_312 = t_311 (t_298)

let t_313 = t_144 (t_312)

let t_314 = t_313 (t_289)

let t_315 = t_147 (t_314)

let t_316 = t_315 (t_153)
let sigmoid = C.(
t_25
)
let nn = C.(
t_152
)
let error = C.(
t_316
)
end
